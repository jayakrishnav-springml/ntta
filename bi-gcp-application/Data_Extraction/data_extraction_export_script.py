import pyodbc
import pandas as pd
from google.cloud import storage
import json
import sys 
import pyarrow as pa
import pyarrow.parquet as pq
import os
import shutil
import google.cloud.logging
import logging
from google.cloud.logging_v2.handlers import CloudLoggingHandler
import subprocess
from multiprocessing import Pool
import mysql.connector
import time
import csv
import gzip
from datetime import datetime


def configure_logging(config):
    """
    Configure logging to write logs.

    Args:
        config (dict): Configuration dictionary containing project_id, log_name, labels, and log_level.

    Returns:
        logging.Logger: Logger object configured for data_transfer.
    """
    log = logging.getLogger('data_transfer')
    client = google.cloud.logging.Client(project=config["project_id"])
    google_handler = CloudLoggingHandler(client, name=config["log"]["log_name"], labels=config["log"]["labels"])
    level = config["log"]["log_level"]
    if level == "DEBUG":
        logging.basicConfig(handlers=[logging.StreamHandler(sys.stderr), google_handler], level=logging.DEBUG)
    elif level == "INFO":
        logging.basicConfig(handlers=[logging.StreamHandler(sys.stderr), google_handler], level=logging.INFO)
    elif level == "WARNING":
        logging.basicConfig(handlers=[logging.StreamHandler(sys.stderr), google_handler], level=logging.WARNING)
    return log

def get_server_connection(config):
    """
    Return connection based on database server type.

    Args:
        config (dict): Configuration dictionary containing database_type and connection_string.

    Returns:
        connection: Connection object based on the database server type.
    """
    if config["database_type"] == "SQLServer":
        connection = pyodbc.connect(config["connection_string"])
    elif config["database_type"] == "MySQL":
        connection = mysql.connector.connect(config["connection_string"])
    return connection

def delete_file(file_path):
    """
    Delete the given file from the system.

    Args:
        file_path (str): Path to the file to be deleted.
    """
    os.remove(file_path)

def create_folder(folder_path):
    """
    Create the directory if it doesn't exist.

    Args:
        folder_path (str): Path to the folder to be created.
    """
    if not os.path.exists(folder_path):
        os.makedirs(folder_path)

def delete_folder(folder_path):
    """
    Delete the directory and all its contents.

    Args:
        folder_path (str): Path to the folder to be deleted.
    """
    shutil.rmtree(folder_path)
    print(f"Directory '{folder_path}' and all its contents deleted")

def upload_to_gcs(source_file_name, table_info, config, log, num_file):
    """
    Uploads a file to Google Cloud Storage (GCS) using gsutil command.

    Args:
        source_file_name (str): The local path of the file to upload.
        table_info (dict): Information about the table including schema_name and table_name.
        config (dict): Configuration dictionary containing output_folder, source_database, compression_type, 
                       parquet_file_page_size_bytes, and database_type.
        log: Logger object for logging messages.
        num_file (int): Number of the file.

    """
    print("file -",source_file_name)
    source_database = config["source_database"]
    schema_name = table_info["schema_name"]
    table_name = table_info["table_name"]
    # if schema_name in config['schema_list']:
    #     destination_database = f"{source_database}_{schema_name}"
    # else:
    #     destination_database = f"{source_database}"
    destination_database = f"{source_database}_{schema_name}"
    # Constructing the gsutil command to upload the file to GCS
    command = ["gsutil", "cp", source_file_name , f"gs://{config['gcs_bucket_name']}/{destination_database}/{table_name}/"]
    # Running the gsutil command test1\master\nulltest\nulltest_1.csv
    # Upload parquet file to GCS in "databasename_schemaname/tablename/" folder.
    print(command)
    subprocess.run(command, check=True, shell=True)
    # Printing a success message if the upload is successful
    print(f"Data loading to GCS for table {destination_database}/{table_name}/{table_name}_{num_file} in {config['database_type']} server is successful.")
    log.info(f"Data loading to GCS for table {destination_database}/{table_name}/{table_name}_{num_file} in {config['database_type']} server is successful.")
    

def check_parquet_file_size_variance(parquet_file):
    """
    Check if Parquet file size is greater than 1 GB. If yes, return the difference; otherwise, return 0.

    Args:
        parquet_file (str): Path to the Parquet file.

    Returns:
        float: Difference in size if greater than 1 GB, else 0.
    """
    file_size_gb = os.path.getsize(parquet_file)/(1024 * 1024 * 1024)  # file size in GB
    if file_size_gb > 1:
        return file_size_gb-1
    else:
        return 0
    
def write_parquet(config, output_file_path, data):
    """
    Write Extracted data from server to Parquet file. Return output file path.

    Args:
        config (dict): Configuration dictionary containing output_folder, source_database, compression_type, 
                       parquet_file_page_size_bytes, and database_type.
        data (dataframe): Extracted data from server.
        output_file_path (str): File path to which data is written.

    Returns:
        str: Output file path.
    """
    table = pa.Table.from_pandas(data)
    pq.write_table(table, output_file_path, compression=config["compression_type"], data_page_size=config["parquet_file_page_size_bytes"])
    return output_file_path

def write_to_compressed_csv(output_file_path, data):
    """
    Write Extracted data from server to Compressed CSV file. Return output file path.

    Args:
        data (dataframe): Extracted data from server.
        output_file_path (str): File path to which data is written.

    Returns:
        str: Output file path.
    """
    with gzip.open(output_file_path, 'wt', encoding='utf-8') as f:
        data.to_csv(f, index=False, sep='|', lineterminator='\n', quoting=csv.QUOTE_ALL)
    return output_file_path

def write_to_csv(output_file_path, data):
    """
    Write Extracted data from server to CSV file. Return output file path.

    Args:
        data (dataframe): Extracted data from server.
        output_file_path (str): File path to which data is written.

    Returns:
        str: Output file path.
    """
    
    with open(output_file_path, 'wt', encoding='utf-8') as f:
        data.to_csv(f, index=False, sep='|', lineterminator='\n', quoting=csv.QUOTE_ALL)
    return output_file_path

def write_csv_to_bucket(data_df, table_info, config, log, num_file):

    storage_client = storage.Client(project=config["project_id"])
    
    bucket_name = config["gcs_bucket_name"]
    bucket = storage_client.bucket(bucket_name)
    
    source_database = config["source_database"]
    schema_name = table_info["schema_name"]
    table_name = table_info["table_name"]
    # if schema_name in config['schema_list']:
    #     destination_database = f"{source_database}_{schema_name}"
    # else:
    #     destination_database = f"{source_database}"
    destination_database = f"{source_database}_{schema_name}"
    folder_path = f"{destination_database}/{table_name}"
    file_name = f"{table_name}_{num_file}{config['file_type']}"
    bucket_folder_path=f"{folder_path}/{file_name}"
    print(bucket_folder_path)

    with bucket.blob(bucket_folder_path).open("wb", ignore_flush=True) as destination:
        data_df.to_csv(destination)


def write_to_file(query, connection, table_info, config, log, num_file, source_schema):
    """
    Extract data from server and write to Parquet/compressed csv/csv file based on file type in config file. Return output file path.

    Args:
        query (str): SQL query to extract data.
        connection: Connection object to the database.
        table_info (dict): Information about the table including schema_name and table_name.
        config (dict): Configuration dictionary containing output_folder, source_database, compression_type, 
                       parquet_file_page_size_bytes, and database_type.
        log: Logger object for logging messages.
        num_file (int): Number of the file.

    Returns:
        str: Output file path.
    """
    output_folder = config["output_folder"]
    source_database = config["source_database"]
    schema_name = table_info["schema_name"]
    table_name = table_info["table_name"]
    # if schema_name in config['schema_list']:
    #     destination_database = f"{source_database}_{schema_name}"
    # else:
    #     destination_database = f"{source_database}"
    destination_database = f"{source_database}_{schema_name}"
    start_extract_time = time.time()
    data = pd.read_sql(query, connection)
    chunk_rows = len(data)
    end_extract_time = time.time()
    print(data.dtypes)
    if len(data) < 1 and num_file == 1:
        output_folder = f"{output_folder}/{destination_database}/NoData/{table_name}"
        output_file_path = f"{output_folder}/{table_name}_{num_file}{config['file_type']}"
    else:
        output_folder = f"{output_folder}/{destination_database}/{table_name}"
        output_file_path = f"{output_folder}/{table_name}_{num_file}{config['file_type']}"
    create_folder(output_folder)
    for index, row in source_schema.iterrows():
        if row['type'] in ['int','bit','integer','bigint','smallint','tinyint']:
            # print(row['column_name'])
            data[row['column_name']] = data[row['column_name']].astype(pd.Int64Dtype())
    print("------changed data types --------")
    print(data.dtypes)
    start_write_time = time.time()
    if "parquet" in config['file_type']:
        write_parquet(config, output_file_path, data)
    elif "csv.gzip" in config['file_type']:
        write_to_compressed_csv(output_file_path, data)
    else:
        # write_to_csv(output_file_path, data)
        
        write_csv_to_bucket(data,table_info,config,log,num_file)
    end_write_time = time.time()
    
    log.info(f"Data extraction for table - {destination_database}/{table_name}_{num_file} in {config['database_type']} server is successful.Extraction time - {end_extract_time - start_extract_time}, write to file/bucket time - {end_write_time-start_write_time}")
    print(f"Data extraction for table - {destination_database}/{table_name}_{num_file} in {config['database_type']} server is successful.")
    return output_file_path, format(end_extract_time - start_extract_time, ".2f"), format(end_write_time-start_write_time, ".2f"), chunk_rows


def upload_file(file_path, table_info, config, log, num_file):
    """
    Upload Parquet file to Google Cloud Storage (GCS) if gcs_upload_flag is set to True or gcs_upload_flag not present in config file.
    Delete the file from the local system once uploaded.

    Args:
        file_path (str): Path to the Parquet file to be uploaded.
        table_info (dict): Information about the table including gcs_upload_flag.
        config (dict): Configuration dictionary containing Google Cloud Storage related configurations.
        log: Logger object for logging messages.
        num_file (int): Number of the file.
    """
    start_upload_time = time.time()
    if "gcs_upload_flag" not in table_info or table_info["gcs_upload_flag"] == "True":
        print("uploading---------")
        upload_to_gcs(file_path, table_info, config, log, num_file)
        # delete_file(file_path) 
    end_upload_time = time.time()
    return format(end_upload_time - start_upload_time, ".2f")


def limit_offset_chunking_approach(table_info, config, log, connection, source_schema):
    """
    Function to extract data from a table in chunks based on the limit and offset values.

    Args:
        table_info (dict): A dictionary containing information about the table.
                           Should contain keys: 'schema_name', 'table_name', 'id_field', 'row_chunk_size'.
                           'schema_name': Name of the schema where the table resides.
                           'table_name': Name of the table.
                           'id_field': Name of the ID column.
                           'row_chunk_size': Size of each chunk in terms of rows to be fetched.
        config (dict): Configuration parameters.
        log: Logger object for logging messages.
        connection: Database connection object.
    """
    offset_count = 1
    chunk_count = 1
    chunk_row_count = int(table_info["row_chunk_size"])
    # Set limit value to chunk_row_count to extract these many rows for each chunk.
    limit_count = chunk_row_count
    count_query = f"SELECT count(*) FROM {table_info.get('schema_name')}.{table_info.get('table_name')}"
    with connection.cursor() as cursor:
        print(f"------------{count_query}-------------")
        cursor.execute(count_query)
        row = cursor.fetchone()
        print(row)
        total_rows = row[0]
    table_rows = 0
    extraction_time, write_time, upload_time = [],[],[]
    # While loop to iterate until the offset count value is less than the total number of rows. Upon reaching a point where the offset count value equals the total number of rows, indicating completion of the extraction process for all rows, the loop terminates.
    while offset_count < total_rows:
        # Based on database_type execute query to extract chunk of data using limit and offset values.
        if config["database_type"] == "SQLServer":
            query = f"SELECT {','.join(map(str, source_schema['column_name']))} FROM (SELECT *, ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS x FROM {table_info.get('schema_name')}.{table_info.get('table_name')}) AS tbl WHERE  tbl.x BETWEEN {offset_count} AND {limit_count};"
        elif config["database_type"] == "MySQL":
            query = f"SELECT * FROM {table_info.get('schema_name')}.{table_info.get('table_name')} LIMIT {limit_count} OFFSET {offset_count}"
        # Write the extracted data to parquet file.
        output_file_path,chunk_extraction_time,chunk_write_time,chunk_rows  = write_to_file(query, connection, table_info, config, log, chunk_count, source_schema)
        chunk_upload_time = upload_file(output_file_path, table_info, config, log, chunk_count)
        extraction_time.append(chunk_extraction_time)
        write_time.append(chunk_write_time)
        upload_time.append(chunk_upload_time)
        table_rows += chunk_rows
        chunk_count = chunk_count + 1
        offset_count = offset_count + chunk_row_count
        limit_count +=  chunk_row_count
    print(f"---------------------------{table_rows}-----------------")
    return extraction_time,write_time,upload_time,table_rows


def discover_idcolumn_minmax(table_info, connection):
    """
    Function to discover the minimum and maximum values of a specified ID column in a database table.

    Args:
        table_info (dict): A dictionary containing information about the table.
                           Should contain keys: 'schema_name', 'table_name', 'id_field'.
                           'schema_name': Name of the schema where the table resides.
                           'table_name': Name of the table.
                           'id_field': Name of the ID column whose minimum and maximum values are to be discovered.
        connection: Database connection object.

    Returns:
        tuple: A tuple containing the minimum and maximum values of the specified ID column.
               If no rows are found, returns None.
    """
    schema_name = table_info["schema_name"]
    table_name = table_info["table_name"]
    id_field = table_info["id_field"]
    min_max_query = f"SELECT min({id_field}), max({id_field}) from {schema_name}.{table_name}"
    print("min_max_query: "+min_max_query)
    cursor = connection.cursor()
    cursor.execute(min_max_query)
    while True:
        row = cursor.fetchone()
        if row == None:
            break
        print(f"minmax for {id_field} in {schema_name}.{table_name}: {row[0]}, {row[1]}")
        return row[0], row[1]

def id_minmax_chunking_approach(table_info, config, log, connection, source_schema):
    """
    Function to extract data from a table in chunks based on the minimum and maximum ID values.

    Args:
        table_info (dict): A dictionary containing information about the table.
                           Should contain keys: 'schema_name', 'table_name', 'id_field', 'row_chunk_size'.
                           'schema_name': Name of the schema where the table resides.
                           'table_name': Name of the table.
                           'id_field': Name of the ID column.
                           'row_chunk_size': Size of each chunk in terms of rows to be fetched.
        config (dict): Configuration parameters.
        log: Logger object for logging messages.
        connection: Database connection object.
    """
    ## Iterate through chunks
    chunk_size = int(table_info["row_chunk_size"])
    min_id, max_id = discover_idcolumn_minmax(table_info, connection)
    schema_name = table_info["schema_name"]
    table_name = table_info["table_name"]
    id_field = table_info["id_field"]
    chunk_count = 1
    table_rows = 0
    extraction_time, write_time, upload_time = [],[],[]
    # id_count_less_than_0_query = f"SELECT Count(*) from  {schema_name}.{table_name} where {id_field} < 0"
    # cursor = connection.cursor()
    # cursor.execute(id_count_less_than_0_query)
    # row = cursor.fetchone()
    if min_id < 0:
        query = f"SELECT * from {schema_name}.{table_name} where {id_field} <= 0"        
        print(f"---------------{query}------------")
        output_file_path,chunk_extraction_time,chunk_write_time,chunk_rows = write_to_file(query, connection, table_info, config, log, chunk_count, source_schema)
        chunk_upload_time = upload_file(output_file_path, table_info, config, log, chunk_count)  
        extraction_time.append(chunk_extraction_time)
        write_time.append(chunk_write_time)
        upload_time.append(chunk_upload_time)
        table_rows += chunk_rows         
        chunk_count+= 1
        min_id = 0
    while min_id < max_id:
        max_chunk_id = min(min_id + chunk_size, max_id)
        if chunk_count == 1:
            query = f"SELECT * from {schema_name}.{table_name} where {id_field} >= {min_id} and {id_field} <= {max_chunk_id}"        
        else:
            query = f"SELECT * from {schema_name}.{table_name} where {id_field} > {min_id} and {id_field} <= {max_chunk_id}"        
        print(f"---------------{query}------------")
        output_file_path,chunk_extraction_time,chunk_write_time,chunk_rows = write_to_file(query, connection, table_info, config, log, chunk_count, source_schema)
        chunk_upload_time = upload_file(output_file_path, table_info, config, log, chunk_count)           
        chunk_count+=1
        min_id = max_chunk_id
        extraction_time.append(chunk_extraction_time)
        write_time.append(chunk_write_time)
        upload_time.append(chunk_upload_time)
        table_rows += chunk_rows
    return extraction_time,write_time,upload_time,table_rows


def extract_and_load_table_data(table_info, config):
    """
    Extracts table data into Parquet files and Loads to GCS.

    Args:
        table_info (dict): Information about the table including schema_name and table_name.
        config (dict): Configuration dictionary containing source_database, database_type, and other parameters.
    """
    log = configure_logging(config)
    start_time = time.time()
    try:
        print("------Process Started------")
        source_database = config["source_database"]
        schema_name = table_info["schema_name"]
        table_name = table_info["table_name"]
        # if schema_name in config['schema_list']:
        #     destination_database = f"{source_database}_{schema_name}"
        # else:
        #     destination_database = f"{source_database}"
        destination_database = f"{source_database}_{schema_name}"
        # Get the connection to server.
        with get_server_connection(config) as connection:
            schema_query = f"SELECT COLUMN_NAME as column_name,DATA_TYPE as type FROM INFORMATION_SCHEMA.COLUMNS WHERE upper(TABLE_NAME) = upper('{table_info.get('table_name')}') and upper(TABLE_SCHEMA) = upper('{table_info.get('schema_name')}');"
            source_schema = pd.read_sql(schema_query, connection)
            # If query is present in configuration file, Extract data using this query and write to one parquet file.
            if "query" in table_info and table_info.get("query","") != "" and table_info["chunk_flag"] == "False":
                print("--------Extracting table data using query in config file-------")
                print("Extracting data using query in config file")
                output_file_path, extraction_time, write_time, total_rows = write_to_file(table_info["query"], connection, table_info, config, log, 1, source_schema)
                upload_time = upload_file(output_file_path, table_info, config, log, 1)
            # If Id column for table is present in configuration file, Extract data from a table in chunks based on the minimum and maximum ID values.
            elif "id_field" in table_info and table_info.get("id_field","") != "":
                print("--------Extracting table data with minmax chunking approach-------")
                extraction_time,write_time,upload_time,total_rows = id_minmax_chunking_approach(table_info, config, log, connection, source_schema)
            # Else, Extract data from a table in chunks based on the limit and offset values.
            else :
                print("--------Extracting table data with limit offset chunking approach-------")
                extraction_time,write_time,upload_time,total_rows = limit_offset_chunking_approach(table_info, config, log, connection, source_schema)
        end_time = time.time()
        execution_time = end_time - start_time
        table_stat = [f"{destination_database}/{table_name}",f"{config['database_type']}",f"{execution_time}",extraction_time, write_time , total_rows]
        print(f"Data extraction for table - {destination_database}/{table_name} in {config['database_type']} server is successful.")
        log.info(f"Data extraction for table - {destination_database}/{table_name} in {config['database_type']} server is successful.")
        print(f"Execution time for extracting and loading -{destination_database}/{table_name} in {config['database_type']} server: {execution_time} seconds")
        log.info(f"Execution time for extracting and loading -{destination_database}/{table_name} in {config['database_type']} server: {execution_time} seconds")
        return table_stat
    
    except Exception as e:
        log.error(f"Error while extracting and loading {destination_database}/{table_name} in {config['database_type']} server: {str(e)}")
        return []


if __name__ == "__main__":
    config_files = eval(sys.argv[1])
    for file_path in config_files:
        with open(file_path, "r") as config_file:
            config = json.load(config_file)
                    
        log = configure_logging(config)
        processes = []
        total_start_time = time.time()
        table_stats = []
        with Pool(processes=config["max_process_count"]) as p:
            # Use starmap to pass multiple arguments to the function
            table_stats.extend(p.starmap(
                extract_and_load_table_data,
                [(table_info, config) for table_info in config["tables"]],
            ))
        
        print(table_stats)
        df = pd.DataFrame(table_stats, columns=['Table Name', 'DataBase server', 'Total Time For extraction', 'Query Extraction Time for each chunk', 'Time for Writing to file/bucket for each chunk','Total Rows' ])
        # Write DataFrame to CSV file
        storage_client = storage.Client(project=config["project_id"])
        bucket = storage_client.bucket(config["gcs_bucket_name"])
        folder_path = "Onetime_Full_Load/"+datetime.now().strftime("%d-%m-%Y")
        file_name = f"DataExtraction_StatisticsLOG_{datetime.now().strftime('%Y%m%d_%H%M%S')}.csv"
        bucket_folder_path=f"{folder_path}/{file_name}"
        with bucket.blob(bucket_folder_path).open("wb", ignore_flush=True) as destination:
            df.to_csv(destination, index=False)
        total_end_time = time.time()
        total_execution_time = total_end_time - total_start_time
        print(f"total time taken------------{total_execution_time}")
        log.info(f"total time taken------------{total_execution_time}")
        
