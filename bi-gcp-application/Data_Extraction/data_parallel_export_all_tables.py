#!/usr/bin/python
import pyodbc
import pandas as pd
from google.cloud import storage
import json
import sys 
import pyarrow as pa
import pyarrow.parquet as pq
import os
import ast
import shutil
import google.cloud.logging
import logging
from google.cloud.logging_v2.handlers import CloudLoggingHandler
from multiprocessing import Pool
import mysql.connector
import time
import csv
import gzip
import concurrent.futures
import subprocess
from datetime import datetime
from google.cloud import secretmanager
from utility.connection import get_connection_string,get_secret

def create_folder(folder_path):
    """
    Create the directory in given path.

    Args:
        folder_path (str): Path to the folder to be created.
    """
    os.makedirs(folder_path)
    print(f"Created new folder: {folder_path}")
    
        

def delete_folder(folder_path):
    """
    Delete the directory and all its contents if directory exists.

    Args:
        folder_path (str): Path to the folder to be deleted.
    """
    if os.path.exists(folder_path):
        shutil.rmtree(folder_path)
        print(f"Deleted existing folder: {folder_path}")

def delete_and_create_log_and_output_folders(log_folder_path, output_folder_path):
    """
    Delete and Create log and output folders.

    Args:
        log_folder_path (str): Path to the log folder.
        output_folder_path (str): Path to the output folder.
    """
    delete_folder(log_folder_path)
    create_folder(log_folder_path)
    delete_folder(output_folder_path)
    create_folder(output_folder_path)
    
def get_input_tables_list(log):
    """
    Retrieve and validate a list of table names from command-line arguments.

    Args:
        log (logging.Logger): Logger object for logging messages.

    Returns:
        list: A list of table names, which are all strings, extracted from the command-line arguments.

    Raises:
        SystemExit: If there are insufficient arguments, if the argument passed
                    is not a list, or if any elements in the list are not strings.
    """
    if len(sys.argv) < 3:
        log.error("List of tables has not been specified as a command line parameter. Please provide the following arguments: `python data_parallel_export_all_tables.py <config file path> ['tablenames']` ")
        time.sleep(5)
        sys.exit(1)
    try:
        tables_to_extract = eval(sys.argv[2])
    except Exception as e:
        log.error("List of tables parameters specified is not a list or in the correct format. Please provide it as ['table1','table2'].")
        time.sleep(5)
        sys.exit(1)    
    
    if not isinstance(tables_to_extract, list):
        log.error("List of tables parameters specified is not a list or in the correct format. Please provide it as ['table1','table2'].")
        time.sleep(5)
        sys.exit(1)
    
    if any(not isinstance(table, str) for table in tables_to_extract):
        log.error("All elements in the List of tables parameters specified should be strings. Please provide it as `['table1','table2']`.")
        time.sleep(5)
        sys.exit(1)
    return tables_to_extract
    
def get_tables_to_Extract_info(config_tables,log,tables_to_extract):
    """
    Retrieve information for specified tables based on a configuration.

    Args:
        config_tables (list of dict): A list of dictionaries where each dictionary contains information about a table.
        log (object): A logging object (currently unused in this function).
        tables_to_extract (list of str): A list of table names to extract information for.

    Returns:
        list of dict: A list of dictionaries containing information for all the tables if the tables_to_extract list is empty; otherwise, for tables in the tables_to_extract list.
    """
    tables_to_extract_info = []
    table_present_flag = 0
    if len(tables_to_extract) == 0:
        tables_to_extract_info = config_tables
    else:
        for table in tables_to_extract:
            table_present_flag = 0
            for table_info in config_tables:
                if table_info['table_name'].lower() == table.lower():
                    tables_to_extract_info.append(table_info)
                    table_present_flag = 1
                    break
            if table_present_flag == 0:
                print(f"{table} table is not present in the list of tables in the configuration file, so this table Extraction will be skipped.")
    return tables_to_extract_info

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

### cmd = ["bcp", f"{query}", "queryout", f"{file_name}", "-d", f"{source_database}", "-a", "32768", "-c", "-t|", "-T", "-q", "-S", "10.40.9.26,17001"]

def process_chunk_parallel(query, file_name, gcs_path, log_folder, log, connection_password,connection_details):
    """
    Process a database chunk in parallel by executing a series of command-line operations.

    Args:
        query (str): SQL query to be used for extracting data.
        file_name (str): The name of the file where the query output will be stored.
        gcs_path (str): Google Cloud Storage path for uploading the file.
        log_folder (str): The directory or file for logging output.
        log (logging.Logger): Logger object for logging messages.
        connection_password (str): Database connection password, if applicable.
        connection_details (dict): Dictionary containing database connection details like server, database, username, etc.

    Returns:
        None
    """
    bcp_out_file_name = f"{log_folder}.out"
    bcp_err_file_name = f"{log_folder}.err"
    print(f"---process_chunk_parallel---{bcp_out_file_name}")
    if connection_password == None :
        steps=[
            {"title": "bcp",      "cmd": ["bcp", f"{query}", "queryout", f"{file_name}", "-d", f"{connection_details['database']}", "-a", "32768", "-c",  "-t|", "-T", "-q", "-S", f"{connection_details['server']}", "-o", f"{bcp_out_file_name}", "-e", f"{bcp_err_file_name}"]},
            {"title": "cp",   "cmd": ["gcloud", "storage", "cp", f"{file_name}", f"{gcs_path}"]},
            {"title": "del",      "cmd": ["del", f"{file_name}"]}
        ]
    else: 
        steps=[
            {"title": "bcp",      "cmd": ["bcp", f"{query}", "queryout", f"{file_name}", "-d", f"{connection_details['database']}", "-a", "32768", "-c",  "-t|", "-U", f"{connection_details['username']}", "-P", f"{connection_password}", "-q", "-S", f"{connection_details['server']}", "-o", f"{bcp_out_file_name}", "-e", f"{bcp_err_file_name}"]},
            {"title": "cp",   "cmd": ["gcloud", "storage", "cp", f"{file_name}", f"{gcs_path}"]},
            {"title": "del",      "cmd": ["del", f"{file_name}"]}
        ]
    for step in steps:
        print(f"Executing step {step['title']}")
        tries = 3
        for i in range(tries):
            try:
                cmd = step["cmd"]
                print(f"Started attempt {i} {cmd}")
                print(*cmd, sep=" ")
                if(step["title"] =="cp" or step["title"] =="del" ):
                    subprocess.run(cmd, shell=True, check=True, capture_output=True) 
                else:
                    subprocess.run(cmd, shell=False, check=True, capture_output=True)   
                if step["title"] == "bcp":
                    log.info(f"Finished step - {step['title']} using {query} and log folder {log_folder} written to file {file_name}")
                else:
                    log.info(f"Finished step - {cmd} ")
                print(f"Finished attempt {i} {cmd}")
                break
            except subprocess.CalledProcessError as error:
                if i < tries-1:
                    print(f"A {step['title']} step for query {query} running exception occurred (will retry):", 
                        "\nERROR: ", error, 
                        "\nSTDOUT: ", error.stdout.decode('utf-8'), 
                        "\nSTDERR: ", error.stderr.decode('utf-8')) 
                    log.error(f" A {step['title']} step for query {query} running exception occurred (will retry):"+ 
                        "\nERROR: "+ error+
                        "\nSTDOUT: "+ error.stdout.decode('utf-8')+ 
                        "\nSTDERR: "+ error.stderr.decode('utf-8'))
                    time.sleep(1)
                    continue
                else:
                    print(f"A {step['title']} step for query {query} running exception occurred (aborting chunk):", 
                        "\nERROR: ", error, 
                        "\nSTDOUT: ", error.stdout.decode('utf-8'), 
                        "\nSTDERR: ", error.stderr.decode('utf-8'))
                    log.error(f" A {step['title']} step for query {query} running exception occurred (aborting chunk):"+ 
                        "\nERROR: "+ error+ 
                        "\nSTDOUT: "+ error.stdout.decode('utf-8')+ 
                        "\nSTDERR: "+ error.stderr.decode('utf-8'))
                    return 
            except Exception as error:
                if i < tries-1:
                    print(f"A {step['title']} invoking exception occurred (will retry):", error)
                    log.error(f" A {step['title']} step for query {query} invoking exception occurred (will retry):", error)
                    time.sleep(1)
                    continue
                else:
                    print(f"A {step['title']} invoking exception occurred (aborting chunk):", error)
                    log.error(f"A {step['title']} step for query {query} invoking exception occurred (aborting chunk):", error)
                    return

def discover_idcolumn_minmax(table_info, connection, log):
    """
    Discover the minimum and maximum values of an ID column in a specified table.

    Args:
        table_info (dict): Information about the table, including schema_name, table_name, and id_field.
        connection (object): A database connection object used to execute SQL queries.
        log (logging.Logger): Logger object for logging messages.

    Returns:
        tuple: A tuple containing:
            - The minimum value of the ID column (or 0 if there's no ID field).
            - The maximum value of the ID column (or 0 if there's no ID field).
            - An SQL query (string) to fetch all rows if the ID field is not specified, or None otherwise.
    """
    schema_name = table_info["schema_name"]
    table_name = table_info["table_name"]
    id_field = table_info["id_field"]
    ## IMPORTANT !! If id_field is empty return SELECT * query with no min max values
    if id_field == "":
        return 0,0,f"SELECT * from {table_info['schema_name']}.{table_info['table_name']}"
    min_max_query = f"SELECT min({id_field}), max({id_field}) from {schema_name}.{table_name} where {id_field} >=0"
    print("-----min_max_query: ------ "+min_max_query)
    cursor = connection.cursor()
    cursor.execute(min_max_query)
    while True:
        row = cursor.fetchone()
        if row == None:
            break
        print(f"minmax for {id_field} in {schema_name}.{table_name}: {row[0]}, {row[1]}")
        return row[0] if row[0] != None else 0, row[1] if row[1] != None else 0, None

def get_query_output(connection,query):
    """
    Execute a given SQL query and return the first row of the result.

    Args:
        connection (object): A database connection object used to execute SQL queries.
        query (str): The SQL query to execute.

    Returns:
        tuple or None: The first row of the query result as a tuple. Returns None if there are no results.
    """
    cursor = connection.cursor()
    cursor.execute(query)
    while True:
        row = cursor.fetchone()
        if row == None:
            break
        return row


def main():
    start_time = datetime.now()
    print(start_time.strftime("%d/%m/%y %H:%M:%S" + " Started"))
    print("------Process Started------")
    file_path = sys.argv[1] ## Pass config json file
    with open(file_path, "r") as config_file:
        config = json.load(config_file)
    log = configure_logging(config)   
    tables_to_extract = get_input_tables_list(log)
    log.info(f"{file_path} {start_time.strftime('%d/%m/%y %H:%M:%S')}------data_parallel_export_all_tables Process Started------ with config {file_path}")
    table_info = {}
    log_folder_path = config["log_folder_path"]
    delete_and_create_log_and_output_folders(log_folder_path, config['output_folder'])
    print(log_folder_path)
    filecount = 0
    source_database = config['connection_details']["database"]
    tables_to_extract_info = get_tables_to_Extract_info(config["tables"],log,tables_to_extract)
    with concurrent.futures.ThreadPoolExecutor(max_workers=int(config["max_process_count"])) as executor:
        for table_info in tables_to_extract_info:
            gcs_path = f"gs://{config['gcs_bucket_name']}/{config['bq_dataset_map'][source_database][table_info['schema_name']]['bq_dataset']}/{config['bq_dataset_map'][source_database][table_info['schema_name']]['table_name_prefix']}{table_info['table_name']}/"
            print("--------------------------------------",gcs_path)
            sql_query=table_info["query"]
            id_field=table_info["id_field"]
            connection_string = get_connection_string(config['project_id'],config['connection_details'])
            if "username" not in config['connection_details'] or config['connection_details']['username'] == "":
                connection_password = None
            else:
                connection_password = get_secret(config['project_id'],config['connection_details']['password_secret_id'],config['connection_details']['secret_version'])
            with pyodbc.connect(connection_string) as connection:
                min_id, max_id, query = discover_idcolumn_minmax(table_info, connection, log)
                total_rows_query = f"SELECT count_big(*) from {table_info['schema_name']}.{table_info['table_name']}"
                total_rows = get_query_output(connection,total_rows_query)[0]
                log.info(f"Total rows in the {table_info['table_name']} table: {total_rows}, Minimum ID where ID > 0: {min_id}, Maximum ID where ID > 0: {max_id}")
            print(f"{table_info['table_name']} discover_idcolumn_minmax query={query}")
            if query != None:
                print(f"NO MIN MAX identified !!! Executing Query instead = {query}------------")
                log.info(f"{file_path} {table_info['table_name']} NO MIN MAX identified !!! Executing Query instead = {query}------------")
                log_folder = f"{log_folder_path}\\{table_info['table_name']}_1"
                executor.submit(process_chunk_parallel, sql_query, f"{config['output_folder']}\\{config['bq_dataset_map'][source_database][table_info['schema_name']]['table_name_prefix']}{table_info['table_name']}_1_of_1.csv", gcs_path, log_folder, log,connection_password,config['connection_details'])
                filecount += 1

                ## Skip chunk count and go to next table in dict
                continue
            
            chunk_count= 1
            chunk_size = int(table_info["row_chunk_size"])
            if (max_id - min_id)%chunk_size == 0:
                total_chunks = int((max_id - min_id)/chunk_size)
            else:
                total_chunks = int((max_id - min_id)/chunk_size) + 1
            id_count_less_than_0_query = f"SELECT count_big(*) from {table_info['schema_name']}.{table_info['table_name']} where {table_info['id_field']} < 0"
            id_less_than_0_count = get_query_output(connection,id_count_less_than_0_query)[0]
            if id_less_than_0_count >  0:
                query = f"{sql_query} where {table_info['id_field']} < 0"        
                print(f"-----------Executing id_less_than_0 Query ={query}------------")
                log.info(f"{file_path} {table_info['table_name']}  Executing id_less_than_0 Query = {query}------------")
                log_folder =""
                log_folder = f"{log_folder_path}\\{table_info['table_name']}_{chunk_count}_of_{total_chunks}"
                print(f"log_folder={log_folder}")
                executor.submit(process_chunk_parallel, query, f"{config['output_folder']}\\{config['bq_dataset_map'][source_database][table_info['schema_name']]['table_name_prefix']}{table_info['table_name']}_{chunk_count}_of_{total_chunks}.csv", gcs_path, log_folder, log,connection_password,config['connection_details'])
                filecount+=1
                chunk_count+= 1
                total_chunks+=1
            
            print(f"{table_info['table_name']} total_chunks:{total_chunks}")
            log.info(f"{file_path} {table_info['table_name']} total_chunks:{total_chunks}")
    
            while min_id < max_id:
                max_chunk_id = min(min_id + chunk_size, max_id)
                if chunk_count == 1 or (chunk_count ==2 and id_less_than_0_count > 0):
                    query = f"{sql_query} where {table_info['id_field']} >= {min_id} and {table_info['id_field']} <= {max_chunk_id}"        
                else:
                    query = f"{sql_query} where {table_info['id_field']} > {min_id} and {table_info['id_field']} <= {max_chunk_id}"        
                print(f"----------Executing Query = {query}------------")
                log.info(f"{file_path} {table_info['table_name']}  Executing Query = {query}------------")
                log_folder =""
                log_folder = f"{log_folder_path}\\{table_info['table_name']}_{chunk_count}_of_{total_chunks}"
                print(f"log_folder={log_folder}")
                executor.submit(process_chunk_parallel, query, f"{config['output_folder']}\\{config['bq_dataset_map'][source_database][table_info['schema_name']]['table_name_prefix']}{table_info['table_name']}_{chunk_count}_of_{total_chunks}.csv", gcs_path, log_folder, log,connection_password,config['connection_details'])

                filecount+=1
                chunk_count+= 1
                min_id = max_chunk_id
        
        executor.shutdown(wait=True)
    finish_time = datetime.now()
    print(finish_time.strftime("%d/%m/%y %H:%M:%S" + " Finished"))
    print(f"JOB Duration={(finish_time - start_time).seconds} seconds with Filecount={filecount}")
    log.info(datetime.now().strftime("%d/%m/%y %H:%M:%S" + f"---data_parallel_export_all_tables--- Finished with config {file_path} !! JOB Duration={(finish_time - start_time).seconds} seconds with Filecount={filecount}") )
    time.sleep(60)

    

if __name__ == '__main__':
    main()

