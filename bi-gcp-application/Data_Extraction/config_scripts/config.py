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
from google.cloud import bigquery
from utility.connection import get_connection_string,get_secret


def get_query_output(connection,query):
    """
    Execute a query on the provided database connection and return the first row of the result.

    Args:
        connection (pyodbc.Connection): Database connection object.
        query (str): SQL query to be executed.

    Returns:
        tuple: The first row of the query result.
    """
    cursor = connection.cursor()
    cursor.execute(query)
    while True:
        row = cursor.fetchone()
        if row == None:
            break
        return row


def generate_table_info(tables_list,id_list):
    """
    Generates a list of dictionaries containing table information based on the input table names.

    Args:
        tables_list (list): List of table names in the format 'schema.table'.
        id_list (list): List of ID fields corresponding to the tables.

    Returns:
        list: List of dictionaries with table information.
    """
    table_info = []
    for i in range(len(tables_list)):
        table_name = tables_list[i]
        if len(id_list) != 0:
            id = id_list[i]
        else:
            id = ""
        schema_name, table_name = table_name.split(".")
        table_info.append({
        "table_name": table_name,
        "schema_name": schema_name,
        "id_field": id,  # Customize as needed
        "row_chunk_size": "2000000",  # Customize as needed
        "chunk_flag": "True",
        "query": "",
        "gcs_upload_flag": "FALSE"
    })
    return table_info

def config_sql_query_from_source(table_info, config):
    """
    Configures the SQL query for a table from the source database schema.

    Args:
        table_info (dict): Dictionary containing table information.
        config (dict): Configuration dictionary containing project ID and connection details.

    Returns:
        dict: Updated table information with the SQL query.
    """
    schema_name = table_info.get('schema_name')
    table_name = table_info.get('table_name')
    connection_string = get_connection_string(config['project_id'],config['connection_details'])
    print(connection_string)
    with pyodbc.connect(connection_string) as connection:
        schema_id_query = f"SELECT SCHEMA_ID('{schema_name}');"
        schema_id = get_query_output(connection,schema_id_query)[0]
        # query = f"SELECT COUNT(*) FROM {table_info.get('schema_name')}.{table_info.get('table_name')};"
                #  select 'select' as x union all select case when system_type_id = 167 then CASE when TagID is NULL then NULL else CONCAT(CHAR(34),REPLACE(REPLACE(REPLACE(TagID, CHAR(34), '\"\"'), CHAR(147), '\"\"'), CHAR(148),'\"\"'), CHAR(34)) end as TagID else concat(name,',') end x from sys.columns where object_id in (select object_id from sys.tables where name='nulltest' and schema_id = 1) union ALL select 'from dbo.nulltest' as x;
        # 
        # query = f"""select 'select' as x union all select case when system_type_id = 167 then concat('CASE when ',name,' is NULL then NULL else CONCAT(CHAR(34), REPLACE(REPLACE(REPLACE(',name,', CHAR(34), ''\\"\\"''), CHAR(147), ''\\"\\"''), CHAR(148),''\\"\\"''), CHAR(34))',' end as ',name,',') else concat(name,',') end as x from sys.columns where object_id in (select object_id from sys.tables where name='{table_name}' and schema_id = {schema_id}) union ALL select 'from {schema_name}.{table_name}' as x"""
        query = f"""select 'select' as x union all select case when system_type_id = 167 then concat('CASE when ',name,' is NULL then NULL else CONCAT(CHAR(34), REPLACE(REPLACE(REPLACE(REPLACE(',name,', CHAR(34), ''\\"\\"''), CHAR(147), ''\\"\\"''), CHAR(148),''\\"\\"''),CHAR(168),'\'\''), CHAR(34))',' end as ',name,',') else concat(name,',') end as x from sys.columns where object_id in (select object_id from sys.tables where name='{table_name}' and schema_id = {schema_id}) union ALL select 'from {schema_name}.{table_name}' as x"""
        # query = f"""select 'select' as x union all select case when system_type_id = 167 then concat('CASE when ',name,' is NULL then NULL else CHAR(34) + REPLACE(REPLACE(REPLACE(',name,', CHAR(34), ''\\"\\"''), CHAR(147), ''\\"\\"''), CHAR(148),''\\"\\"'') + CHAR(34)',' end as ',name,',') else concat(name,',') end as x from sys.columns where object_id in (select object_id from sys.tables where name='{table_name}' and schema_id = {schema_id}) union ALL select 'from {schema_name}.{table_name}' as x"""
        # query = "select 'select' as x union all select case when system_type_id = 167 then concat('CONCAT(CHAR(34), REPLACE(REPLACE(REPLACE(',name,', CHAR(34), ''\"\"''), CHAR(147), ''\"\"''), CHAR(148),''\"\"''), CHAR(34))',' as ',name,',') else concat(name,',') end x from sys.columns where object_id in (select object_id from sys.tables where name='nulltest' and schema_id = 1) union ALL select 'from dbo.nulltest' as x;"
        data = pd.read_sql(query, connection)
        sql_query = ' '.join(map(str, data['x']))
        sql_query = sql_query.replace(", from", " from")
        query = f"SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = '{table_name}' and TABLE_SCHEMA = '{schema_name}';"
        data = pd.read_sql(query, connection)
        print(data)
        # print(data.columns)
        for i in range(len(data['DATETIME_PRECISION'])):
            if data['DATETIME_PRECISION'][i] == 7:
                print("------------------------------------------------")
                col = data['COLUMN_NAME'][i]
                datatype = data['DATA_TYPE'][i]
                sql_query = sql_query.replace(f", {col},", f", CAST({col} AS {datatype}(6)) AS {col},")
                sql_query = sql_query.replace(f", {col} from", f", CAST({col} AS {datatype}(6)) AS {col} from")
                sql_query = sql_query.replace(f"select {col},", f"select CAST({col} AS {datatype}(6)) AS {col},")
            if ' ' in data['COLUMN_NAME'][i] or '/' in data['COLUMN_NAME'][i] or '_' in data['COLUMN_NAME'][i]:
                col = data['COLUMN_NAME'][i]
                sql_query = sql_query.replace(f", {col},", f", [{col}],")
                sql_query = sql_query.replace(f"select {col},", f"select [{col}],")
                # sql_query = sql_query.replace(f", CASE when {col} is NULL then NULL else CONCAT(CHAR(34), REPLACE(REPLACE(REPLACE({col}, CHAR(34), '\\\"\\\"'), CHAR(147), '\\\"\\\"'), CHAR(148),'\\\"\\\"'), CHAR(34)) end as {col},", f", CASE when [{col}] is NULL then NULL else CONCAT(CHAR(34), REPLACE(REPLACE(REPLACE([{col}], CHAR(34), '\\\"\\\"'), CHAR(147), '\\\"\\\"'), CHAR(148),'\\\"\\\"'), CHAR(34)) end as [{col}],")
                sql_query = sql_query.replace(f", CASE when {col} is NULL then NULL else CONCAT(CHAR(34), REPLACE(REPLACE(REPLACE(REPLACE({col}, CHAR(34), '\\\"\\\"'), CHAR(147), '\\\"\\\"'), CHAR(148),'\\\"\\\"'),CHAR(168),''), CHAR(34)) end as {col},", f", CASE when [{col}] is NULL then NULL else CONCAT(CHAR(34), REPLACE(REPLACE(REPLACE(REPLACE([{col}], CHAR(34), '\\\"\\\"'), CHAR(147), '\\\"\\\"'), CHAR(148),'\\\"\\\"'),CHAR(168),''), CHAR(34)) end as [{col}],")
                # sql_query = sql_query.replace(f", CASE when {col} is NULL then NULL else CHAR(34) + REPLACE(REPLACE(REPLACE({col}, CHAR(34), '\\\"\\\"'), CHAR(147), '\\\"\\\"'), CHAR(148),'\\\"\\\"') + CHAR(34) end as {col},", f", CASE when [{col}] is NULL then NULL else CHAR(34) + REPLACE(REPLACE(REPLACE([{col}], CHAR(34), '\\\"\\\"'), CHAR(147), '\\\"\\\"'), CHAR(148),'\\\"\\\"') + CHAR(34) end as [{col}],")
        # print(sql_query)
        table_info['query'] = sql_query.replace('\\\"\\', '\"')
    return table_info

def get_bigquery_query_result(project_id, query):
    """
    Execute a query on BigQuery and return the result as a DataFrame.

    Args:
        project_id (str): Project ID of the Google Cloud Platform (GCP) environment.
        query (str): SQL query to be executed on BigQuery.

    Returns:
        pandas.DataFrame: Result of the query as a DataFrame.
    """
    bq_client = bigquery.Client(project=project_id)
    # print(query)
    # Execute the query
    query_job = bq_client.query(query)
    # Wait for the query to complete
    result = query_job.result().to_dataframe()
    return result

def config_sql_query_from_bq(table_info, config):
    """
    Configures the SQL query for a table from BigQuery Schema.

    Args:
        table_info (dict): Dictionary containing table information.
        config (dict): Configuration dictionary containing project ID and connection details.

    Returns:
        dict: Updated table information with the SQL query.
    """
    schema_name = table_info.get('schema_name')
    table_name = table_info.get('table_name')
    connection_string = get_connection_string(config['project_id'],config['connection_details'])
    # print(connection_string)
    with pyodbc.connect(connection_string) as connection:
        query = f"""select 'select' as x union all select case when data_type = 'STRING' then concat('CASE when ',column_name,' is NULL then NULL else CONCAT(CHAR(34), REPLACE(REPLACE(REPLACE(',column_name,', CHAR(34), ' '\\'\\\\"\\\\"\\'' '), CHAR(147), ' '\\'\\\\"\\\\"\\'' '), CHAR(148),' '\\'\\\\"\\\\"\\'' '), CHAR(34))',' end as ',column_name,',') else concat(column_name,',') end as x from LND_TBOS.INFORMATION_SCHEMA.COLUMNS where table_name='{schema_name}_{table_name}' union ALL select 'from {schema_name}.{table_name} WITH (NOLOCK)' as x"""
        data = get_bigquery_query_result(config['project_id'],query)
        sql_query = ' '.join(map(str, data['x']))
        sql_query = sql_query.replace(f" from {schema_name}.{table_name} WITH (NOLOCK)", "")
        sql_query = sql_query.replace(f"select ", "")
        sql_query = sql_query.replace(f"select", "")
        print(sql_query)
        if schema_name not in ["EIP","MIR","Reporting"]:
            database  = "TBOS"
            query = f"SELECT * FROM TBOS.INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = '{table_name}' and TABLE_SCHEMA = '{schema_name}';"
        elif schema_name in ["Reporting"]:
            database  = "TBOSRPT"
            query = f"SELECT * FROM TBOSRPT.INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = '{table_name}' and TABLE_SCHEMA = '{schema_name}';"
        else:
            database  = "IPS"
            query = f"SELECT * FROM IPS.INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = '{table_name}' and TABLE_SCHEMA = '{schema_name}';"
        sql_query = "select " + sql_query[:-1] + f" from {database}.{schema_name}.{table_name} WITH (NOLOCK)"
        data = pd.read_sql(query, connection)
        print(data)
        for i in range(len(data['DATETIME_PRECISION'])):
            if data['DATA_TYPE'][i] == 'bit':
                print("bit column")
                col = data['COLUMN_NAME'][i].lower()
                sql_query = sql_query.replace(f", {col},", f", CASE when {col} is NULL then 0 else {col} end AS {col},")
                sql_query = sql_query.replace(f", {col} from", f", CASE when {col} is NULL then 0 else {col} end AS {col} from")
                sql_query = sql_query.replace(f"select {col},", f"select CASE when {col} is NULL then 0 else {col} end AS {col},")
            if data['DATETIME_PRECISION'][i] == 7:
                print("------------------------------------------------")
                col = data['COLUMN_NAME'][i].lower()
                datatype = data['DATA_TYPE'][i]
                sql_query = sql_query.replace(f", {col},", f", CAST({col} AS {datatype}(6)) AS {col},")
                sql_query = sql_query.replace(f", {col} from", f", CAST({col} AS {datatype}(6)) AS {col} from")
                sql_query = sql_query.replace(f"select {col},", f"select CAST({col} AS {datatype}(6)) AS {col},")
            if ' ' in data['COLUMN_NAME'][i] or '/' in data['COLUMN_NAME'][i] or '_' in data['COLUMN_NAME'][i]:
                col = data['COLUMN_NAME'][i].lower()
                print(col)
                sql_query = sql_query.replace(f", {col},", f", [{col}],")
                sql_query = sql_query.replace(f"select {col},", f"select [{col}],")
                sql_query = sql_query.replace(f", CASE when {col} is NULL then NULL else CONCAT(CHAR(34), REPLACE(REPLACE(REPLACE({col}, CHAR(34), '\\\"\\\"'), CHAR(147), '\\\"\\\"'), CHAR(148),'\\\"\\\"'), CHAR(34)) end as {col},", f", CASE when [{col}] is NULL then NULL else CONCAT(CHAR(34), REPLACE(REPLACE(REPLACE([{col}], CHAR(34), '\\\"\\\"'), CHAR(147), '\\\"\\\"'), CHAR(148),'\\\"\\\"'), CHAR(34)) end as [{col}],")
                # sql_query = sql_query.replace(f", CASE when {col} is NULL then NULL else CONCAT(CHAR(34), REPLACE(REPLACE(REPLACE(REPLACE({col}, CHAR(34), '\\\"\\\"'), CHAR(147), '\\\"\\\"'), CHAR(148),'\\\"\\\"'),CHAR(168),''), CHAR(34)) end as {col},", f", CASE when [{col}] is NULL then NULL else CONCAT(CHAR(34), REPLACE(REPLACE(REPLACE(REPLACE([{col}], CHAR(34), '\\\"\\\"'), CHAR(147), '\\\"\\\"'), CHAR(148),'\\\"\\\"'),CHAR(168),''), CHAR(34)) end as [{col}],")
                # sql_query = sql_query.replace(f", CASE when {col} is NULL then NULL else CHAR(34) + REPLACE(REPLACE(REPLACE({col}, CHAR(34), '\\\"\\\"'), CHAR(147), '\\\"\\\"'), CHAR(148),'\\\"\\\"') + CHAR(34) end as {col},", f", CASE when [{col}] is NULL then NULL else CHAR(34) + REPLACE(REPLACE(REPLACE([{col}], CHAR(34), '\\\"\\\"'), CHAR(147), '\\\"\\\"'), CHAR(148),'\\\"\\\"') + CHAR(34) end as [{col}],")
        sql_query = sql_query.replace(f", lnd_updatedate, CASE when lnd_updatetype is NULL then NULL else CONCAT(CHAR(34), REPLACE(REPLACE(REPLACE(lnd_updatetype, CHAR(34), '\\\"\\\"'), CHAR(147), '\\\"\\\"'), CHAR(148),'\\\"\\\"'), CHAR(34)) end as lnd_updatetype, src_changedate", ", GETDATE() AS LND_UpdateDate, 'I' AS LND_UpdateType, NULL AS SRC_ChangeDate")
        print(sql_query)
        table_info['query'] = sql_query.replace('\\\"\\', '\"')
    return table_info

if __name__ == "__main__":
    config_file_path = sys.argv[1]
    file_path = sys.argv[2]
    with open(config_file_path, "r") as config_file:
        parameters_config = json.load(config_file) 
    tables_list = parameters_config["tables_list"]
    id_list = parameters_config["id_list"]
    tables_info = generate_table_info(tables_list,id_list)
    print(tables_info)
    with open(file_path, "r") as json_file:
        config = json.load(json_file)                    
        table_stats = []
        for table_info in tables_info:
            if parameters_config["get_schema_from"] == "source":
                table_stats.append(config_sql_query_from_source(table_info, config))
            else:
                table_stats.append(config_sql_query_from_bq(table_info, config))
        config["tables"] += table_stats
        with open(file_path, "w") as json_file:
            json.dump(config, json_file, indent=4)
    