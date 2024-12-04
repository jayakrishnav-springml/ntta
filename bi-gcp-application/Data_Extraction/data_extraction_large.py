from utility.connection import get_connection_string,get_secret
from utility.count import discover_idcolumn_minmaxcount
import math, pyodbc, sys, json, numpy as np
from data_parallel_export_all_tables import process_chunk_parallel, configure_logging, get_query_output
import concurrent.futures
from datetime import datetime


def main():
    start_time = datetime.now()
    print(start_time.strftime("%d/%m/%y %H:%M:%S" + " Started"))
    print("------Process Started------")    
    file_path = sys.argv[1] ## Pass config json file
    with open(file_path, "r") as config_file:
        config = json.load(config_file)
    # log =  type('LOG', (object,), {'info': lambda arg: arg})()
    log = configure_logging(config)  
    connection_string = get_connection_string(config['project_id'],config['connection_details'])
    source_database = config['connection_details']["database"]
    log_folder_path = config["log_folder_path"]
    if "username" not in config['connection_details'] or config['connection_details']['username'] == "":
        connection_password = None
    else:
        connection_password = get_secret(config['project_id'],config['connection_details']['password_secret_id'],config['connection_details']['secret_version'])
    
    for table_info in config["tables"]:            
        gcs_path = f"gs://{config['gcs_bucket_name']}/{config['bq_dataset_map'][source_database][table_info['schema_name']]['bq_dataset']}/{config['bq_dataset_map'][source_database][table_info['schema_name']]['table_name_prefix']}{table_info['table_name']}/"
        sql_query=table_info["query"]
        id_field=table_info["id_field"]
        
        query_arr = []
        with pyodbc.connect(connection_string) as connection:
            min_id, max_id, query, total_ids = discover_idcolumn_minmaxcount(table_info, connection, log)
            print(f"min_id: {min_id}, max_id: {max_id}, total_ids: {total_ids}")
            # Assuming all IDs are present# Define bin sizes            
            bin_width = 2000000
            num_samples = math.ceil(total_ids/bin_width)
            print(f" num_samples: {num_samples}")
            
            bin_arr = np.linspace(float(min_id), float(max_id), num_samples)
            print(f"bin_arr: {bin_arr} size: {len(bin_arr)}")
            id_count_less_than_0_query = f"SELECT count(*) from {table_info['schema_name']}.{table_info['table_name']} where {table_info['id_field']} < 0"
            id_less_than_0_count = get_query_output(connection,id_count_less_than_0_query)[0]
            if id_less_than_0_count >  0:
                query = f"{sql_query} where {table_info['id_field']} < 0"  
                query_arr.append(query) 
            count=0
            previtem = None            
            for i in range(len(bin_arr)):  
                if i == 0:  # First item
                    query = f"{sql_query} WHERE {id_field} >= {min_id} and {id_field} <= {format(bin_arr[i], '.35g')}"
                else:
                    query = f"{sql_query} WHERE {id_field} > {previtem} and {id_field} <= {format(bin_arr[i], '.35g')}"
                query_arr.append(query)
                print(f"Query {i+1}: {query}")
                previtem = format(bin_arr[i], '.35g')

            # Last item
            final_query = f"{sql_query} WHERE {id_field} > {previtem} and {id_field} <= {max_id}"
            query_arr.append(final_query)
            print(f"Final Query: {final_query}")
            with concurrent.futures.ThreadPoolExecutor(max_workers=int(config["max_process_count"])) as executor:
                qcount=1
                for query in query_arr:
                    log_folder = f"{log_folder_path}\\{table_info['table_name']}_{qcount}_of_{len(query_arr)}"
                    executor.submit(process_chunk_parallel, query, f"{config['output_folder']}\\{config['bq_dataset_map'][source_database][table_info['schema_name']]['table_name_prefix']}{table_info['table_name']}_{qcount}_of_{len(query_arr)}.csv", gcs_path, log_folder, log,connection_password,config['connection_details'])
                    qcount+=1
    executor.shutdown(wait=True)
    finish_time = datetime.now()
    print(finish_time.strftime("%d/%m/%y %H:%M:%S" + " Finished"))
    print(f"JOB Duration={(finish_time - start_time).seconds} seconds")
    log.info(datetime.now().strftime("%d/%m/%y %H:%M:%S" + f"---data_parallel_export_all_tables--- Finished with config {file_path} !! JOB Duration={(finish_time - start_time).seconds} seconds") )


            

if __name__ == '__main__':
    main()