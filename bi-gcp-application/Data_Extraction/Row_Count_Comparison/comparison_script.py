import pyodbc
import sys
import json
import google.cloud.logging
import logging
from google.cloud import bigquery
from google.cloud.logging_v2.handlers import CloudLoggingHandler
import pandas as pd
from datetime import datetime, date
import time
from utility.connection import get_connection_string


def get_tables_names(project_id, config_dataset, config_table, comparisonrunflag, source_database, log):
    """
    Retrieves the names of tables and realted details that require row count comparison from the configuration table.

    Args:
        project_id (str): Project ID of the Google Cloud Platform (GCP) environment.
        config_dataset (str): Dataset name of BQ where comparison tables names are stored.
        config_table (str): Table name of BQ where comparison tables names are stored.
        comparisonrunflag (str): Flag to filter tables that need to be compared.
    Returns:
        Result of the query as a DataFrame.
    """
    query = f"select sourcedatabase, sourceschema, sourcetable, keycolumn, landingdataset, landingtable, comparisonrunflag, level2checkflag, groupbycolumn from {config_dataset}.{config_table} where comparisonrunflag='{comparisonrunflag}' and sourcedatabase='{source_database}';"
    log.info(
        f"Query to retrieve the table names that need row count comparison: {query}"
    )
    return get_bigquery_query_result(project_id, query)


def get_sql_server_row_count(connection, source_query):
    """
    Execute a SQL query on a SQL Server database and return the result.

    Args:
        connection (str): Connection string for the SQL Server database.
        source_query (str): SQL query to be executed on the SQL Server database.

    Returns:
        Result of the query.
    """

    cursor = connection.cursor()
    cursor.execute(source_query)
    source_query_result = cursor.fetchall()
    cursor.close()
    return source_query_result


def get_bigquery_query_result(project_id, query):
    """
    Execute a query on BigQuery and return the result as a DataFrame.

    Args:
        project_id (str): Project ID of the Google Cloud Platform (GCP) environment.
        query (str): SQL query to be executed on BigQuery.

    Returns:
        Result of the query as a DataFrame.
    """
    bq_client = bigquery.Client(project=project_id)
    # Execute the query
    query_job = bq_client.query(query)
    # Wait for the query to complete
    result = query_job.result().to_dataframe()
    return result


def configure_logging(config):
    """
    Configure logging to write logs.

    Args:
        config (dict): Configuration dictionary containing project_id, log_name, labels, and log_level.

    Returns:
        logging.Logger: Logger object configured for data_transfer.
    """
    log = logging.getLogger("src_vs_bq_row_comparison")
    client = google.cloud.logging.Client(project=config["project_id"])
    google_handler = CloudLoggingHandler(
        client, name=config["log"]["log_name"], labels=config["log"]["labels"]
    )
    level = config["log"]["log_level"]
    if level == "DEBUG":
        logging.basicConfig(
            handlers=[logging.StreamHandler(sys.stderr), google_handler],
            level=logging.DEBUG,
        )
    elif level == "INFO":
        logging.basicConfig(
            handlers=[logging.StreamHandler(sys.stderr), google_handler],
            level=logging.INFO,
        )
    elif level == "WARNING":
        logging.basicConfig(
            handlers=[logging.StreamHandler(sys.stderr), google_handler],
            level=logging.WARNING,
        )
    return log


def compare_row_count(
    project_id,
    connection,
    sourcedatabase,
    sourceschema,
    sourcetable,
    keycolumn,
    landingdataset,
    landingtable,
    log,
):
    """
    Compare the row count between a source table and a BigQuery table.

    Args:
        project_id (str): Project ID of the Google Cloud Platform (GCP) environment.
        connection (str): Connection string for the source database.
        sourcedatabase (str): Source database name.
        sourceschema (str): Name of the schema for the source table.
        sourcetable (str): Name of the source table.
        keycolumn (str): Name of the ID column.
        landingdataset (str): Name of the BigQuery dataset to query table.
        landingtable (str): Name of the BigQuery table.
        log (str): Logging information.

    Returns:
        source_row_count (int): Row count of the source table.
        bq_row_count (int): Row count of the BigQuery table.
        comparison_status (str): Status of the comparison (Pass/Fail/None).
    """

    log.info(
        f"------------------Compare the row count between source {sourcedatabase}.{sourceschema}.{sourcetable} and BigQuery {landingdataset}.{landingtable}.-------------------------------------------"
    )
    row_count_diff = 0
    try:
        bq_query = f"select min({keycolumn}) as min_id, max({keycolumn}) as max_id, count(1) as row_count from {landingdataset}.{landingtable} WHERE lnd_updatetype NOT IN ('A', 'D');"
        log.info(
            f"Query to retrieve row count from BigQuery table '{landingtable}': {bq_query}"
        )
        bq_query_result = get_bigquery_query_result(project_id, bq_query)
        min_id = bq_query_result["min_id"].iloc[0]
        max_id = bq_query_result["max_id"].iloc[0]
        bq_row_count = bq_query_result["row_count"].iloc[0]
        # If the query result has no records, then no comparison will be performed for this table.
        if pd.isna(min_id) and bq_row_count == 0:
            log.warning(
                f"The query result: {bq_query} has no records, so no comparison will be performed for this table."
            )
            return {"comparison_status": "None"}
        # Condition to check whether max_id is of integer type; if not, no comparison will be performed for this table.
        if bq_query_result["max_id"].dtype != "Int64":
            log.warning(
                f"The ID column for the BigQuery table {landingdataset}.{landingtable} is not of the INTEGER type. Therefore, row comparison for {landingtable} will not be performed."
            )
            return {"comparison_status": "None"}
    except Exception as error:
        log.error(
            f"There's an issue querying the table {landingdataset}.{landingtable} in BigQuery. The specific error message is: {error}."
        )
        return {"comparison_status": "None"}
    try:
        execution_start_time = datetime.now()
        source_query = f"select COUNT_BIG(1) as row_count from {sourcedatabase}.{sourceschema}.{sourcetable} WITH (NOLOCK) where {keycolumn} <={max_id};"
        log.info(
            f"Query to retrieve row count from source table '{sourcedatabase}.{sourceschema}.{sourcetable}': {source_query}"
        )
        source_row_count = get_sql_server_row_count(connection, source_query)[0][0]
        execution_end_time = datetime.now()
    except Exception as error:
        log.error(
            f"There's an issue querying the table {sourcedatabase}.{sourceschema}.{sourcetable} in source. The specific error message is: {error}."
        )
        return {"comparison_status": "None"}
    if bq_row_count == source_row_count:
        comparison_status = "Pass"
    else:
        comparison_status = "Fail"
        row_count_diff = source_row_count - bq_row_count

    return {
        "source_row_count": source_row_count,
        "bq_row_count": bq_row_count,
        "comparison_status": comparison_status,
        "row_count_diff": row_count_diff,
        "source_execution_time": round(((execution_end_time - execution_start_time).total_seconds()), 3),
    }


def load_dataframe_to_bq_table(project_id, bq_dataset, bq_table, dataframe, log):
    """
    Load a Pandas DataFrame into a BigQuery table.

    Args:
        project_id (str): Project ID of the Google Cloud Platform (GCP) environment.
        bq_dataset (str): Name of the destination BigQuery dataset.
        bq_table (str): Name of the destination BigQuery table.
        dataframe (pandas.DataFrame): DataFrame to be loaded into the BigQuery table.
    """
    bq_client = bigquery.Client(project=project_id)

    # Construct the table reference
    table_ref = f"{project_id}.{bq_dataset}.{bq_table}"
    if not dataframe.empty:
        # Load the DataFrame into the BigQuery table
        bq_client.load_table_from_dataframe(dataframe, table_ref).result()
    else:
        log.info(
            f"The query result is empty, no records will be inserted into the table: {bq_dataset}.{bq_table}"
        )


def query_comparison_failed_table(
    connection,
    project_id,
    sourcedatabase,
    sourceschema,
    sourcetable,
    landingdataset,
    landingtable,
    bq_level2_check_result_table,
    source_level2_check_result_table,
    destination_dataset,
    groupbycolumn,
    current_date,
    date_range,
    run_id,
    log,
):
    """
    Retrieve results from the source and Google BigQuery (GBQ) based on the date range, and load the queried results into GBQ tables.

    Args:
        connection (str): Connection string for the source database.
        project_id (str): Project ID of the Google Cloud Platform (GCP) environment.
        sourcedatabase (str): Name of the source database.
        sourceschema (str): Name of the source schema.
        sourcetable (str): Name of the source table.
        landingdataset (str): Name of the BigQuery dataset.
        landingtable (str): Name of the BigQuery table.
        bq_level2_check_result_table (dict): Name of the table where the Level 2 check results for BigQuery need to be inserted.
        source_level2_check_result_table (dict): Name of the table where the Level 2 check results for Source need to be inserted.
        groupbycolumn (str): The column name used to perform the GROUP BY clause in Level 2 check queries for each table.
        date_range(int): This indicates that the filter is used to retrieve data only from the specified number of past days.
        run_id(int): A unique ID representing the count of script executions.
        log (str): Logging information.
    """
    try:

        if date_range > 0:
            bq_level2_check_query = f"select '{landingdataset}' as datasetname, '{landingtable}' as tablename, CAST({groupbycolumn} as DATE) AS createddate, COUNT(1) AS landingrowcount,CURRENT_DATETIME() AS lnd_updatedate, {run_id} as executionid FROM {landingdataset}.{landingtable} WHERE lnd_updatetype NOT IN ('A', 'D') and {groupbycolumn} between DATE_SUB(DATE '{current_date}', INTERVAL {date_range} DAY) and '{current_date}' GROUP BY {groupbycolumn};"
        else:
            bq_level2_check_query = f"select '{landingdataset}' as datasetname, '{landingtable}' as tablename, CAST({groupbycolumn} as DATE) AS createddate, COUNT(1) AS landingrowcount,CURRENT_DATETIME() AS lnd_updatedate, {run_id} as executionid FROM {landingdataset}.{landingtable} WHERE lnd_updatetype NOT IN ('A', 'D') GROUP BY {groupbycolumn};"
        log.info(
            f"Retrieve data for a level 2 check from the '{landingdataset}.{landingtable}' table in BigQuery using the following query: {bq_level2_check_query}"
        )
        bq_level2_check_query_result = get_bigquery_query_result(
            project_id, bq_level2_check_query
        )
        log.info(
            f"Loading result of queried BigQuery data for {landingdataset}.{landingtable} into the destination table: {destination_dataset}.{bq_level2_check_result_table}."
        )
        load_dataframe_to_bq_table(
            project_id,
            destination_dataset,
            bq_level2_check_result_table,
            bq_level2_check_query_result,
            log,
        )
    except Exception as error:
        log.error(
            f"Encountered an error while querying results for level 2 check from the '{landingdataset}.{landingtable}' table in BigQuery. The specific error message is: '{error}'."
        )
    try:
        if date_range > 0:
            source_level2_check_query = f"SELECT '{sourcedatabase}' databasename, '{sourceschema}.{sourcetable}' tablename,  CAST({groupbycolumn} AS DATE) AS createddate,  COUNT_BIG(1) sourcerowcount,  CAST (SYSDATETIME () AS DATETIME2(3)) AS lnd_updatedate,{run_id} as executionid FROM {sourcedatabase}.{sourceschema}.{sourcetable} WITH (NOLOCK) WHERE {groupbycolumn} between  DATEADD(DAY, -{date_range}, '{current_date}') and CAST('{current_date}' as DATE) GROUP BY CAST ({groupbycolumn} AS DATE);"
        else:
            source_level2_check_query = f"SELECT '{sourcedatabase}' databasename, '{sourceschema}.{sourcetable}' tablename,  CAST({groupbycolumn} AS DATE) AS createddate,  COUNT_BIG(1) sourcerowcount,  CAST (SYSDATETIME () AS DATETIME2(3)) AS lnd_updatedate,{run_id} as executionid FROM {sourcedatabase}.{sourceschema}.{sourcetable} WITH (NOLOCK) GROUP BY CAST ({groupbycolumn} AS DATE);"
        log.info(
            f"Query to retrieve data for a level 2 check from the table '{sourcedatabase}.{sourceschema}.{sourcetable}' in Source: {source_level2_check_query}"
        )
        level2_execution_start_time = datetime.now()
        source_query_result_df = pd.read_sql(source_level2_check_query, connection)
        level2_execution_end_time = datetime.now()
        log.info(
            f"Loading result of queried source data for '{sourcedatabase}.{sourceschema}.{sourcetable}' into the destination table: {destination_dataset}.{source_level2_check_result_table}."
        )
        source_query_result_df["sourceexectimeinsec"] = round(((level2_execution_end_time - level2_execution_start_time).total_seconds()), 3)
        load_dataframe_to_bq_table(
            project_id,
            destination_dataset,
            source_level2_check_result_table,
            source_query_result_df,
            log,
        )
    except Exception as error:
        log.error(
            f"Encountered an error while querying results for level 2 check from the '{sourcedatabase}.{sourceschema}.{sourcetable}' table in Source. The specific error message is: {error}."
        )


def get_execution_id(project_id, destination_dataset, comparison_result_table, log):
    """
    Retrieve the execution ID from a BigQuery table and increment it with one.

    Parameters:
        project_id (str): The project ID.
        destination_dataset (str): The destination dataset name in BigQuery.
        comparison_result_table (str): The name of the table in BigQuery.
        log (Logger): The logger object for logging.

    Returns:
        int: The execution ID.

    """
    get_execution_id_query = f"select max(executionid) as executionid from {destination_dataset}.{comparison_result_table};"
    log.info(
        f"Query to retrieve execution_id from '{destination_dataset}.{comparison_result_table}' table in BigQuery using the following query:{get_execution_id_query}."
    )
    bq_execution_id_query_result = get_bigquery_query_result(
        project_id, get_execution_id_query
    )
    execution_id = bq_execution_id_query_result["executionid"].iloc[0]
    if pd.isna(execution_id) or execution_id <= 0:
        return 1
    return int(execution_id) + 1


def main():
    file_path = sys.argv[1]
    with open(file_path, "r") as config_file:
        config = json.load(config_file)
    connection_mapping={}
    for connection_details in config.get("connection_details",""):
        connection_string = get_connection_string(
            config["project_id"], connection_details
        )
        connection_mapping[connection_details.get("database","")] = connection_string

    project_id = config.get("project_id", "")
    tables_list_info = config.get("tables_list_info", "")
    date_range = config.get("date_range", "")
    destination_table_info = config.get("destination_table_info", "")
    destination_dataset = destination_table_info.get("destination_dataset", "")
    comparison_result_table = destination_table_info.get("comparison_result_table", "")
    bq_level2_check_result_table = destination_table_info.get(
        "bq_level2_check_result_table", ""
    )
    source_level2_check_result_table = destination_table_info.get(
        "source_level2_check_result_table", ""
    )
    log = configure_logging(config=config)
    log.info("------script for row count comparison started.------")
    try:
        # Fetch the unique execution ID.
        run_id = get_execution_id(
            project_id, destination_dataset, comparison_result_table, log
        )
        current_date = date.today()
        for source_database in connection_mapping:
            with pyodbc.connect(connection_mapping[source_database]) as connection:
                # Retrieves the names of tables and related details from the configuration table, based on source_database name, that require row count comparison.
                tables_list = get_tables_names(
                    project_id,
                    tables_list_info.get("dataset_name", ""),
                    tables_list_info.get("table_name", ""),
                    tables_list_info.get("comparisonrunflag", ""),
                    source_database,
                    log,
                )
                
                # Iterate through each table, compare the row count from the source and Google BigQuery (GBQ), and perform the Level 2 check for tables based on the flag set in the configuration table.
                for index, row in tables_list.iterrows():
                    current_datetime = datetime.now()
                    sourcedatabase = row.get("sourcedatabase", "")
                    sourceschema = row.get("sourceschema", "")
                    sourcetable = row.get("sourcetable", "")
                    keycolumn = row.get("keycolumn", "").split(",")[0].strip()
                    landingdataset = row.get("landingdataset", "")
                    landingtable = row.get("landingtable", "")
                    level2checkflag = row.get("level2checkflag", "")
                    groupbycolumn = row.get("groupbycolumn", "")
                    # Level One Check.
                    stats_info = compare_row_count(
                        project_id,
                        connection,
                        sourcedatabase,
                        sourceschema,
                        sourcetable,
                        keycolumn,
                        landingdataset,
                        landingtable,
                        log,
                    )
                    # Insert the result of the Level one check into (GBQ) and proceed with the Level 2 check for tables based on the flag set in the configuration table.
                    if stats_info.get("comparison_status") != "None":
                        row_count_compare_data = [
                            {
                                "comparisondatetime": current_datetime,
                                "sourcetablename": sourcetable,
                                "landingtablename": landingtable,
                                "sourcerowcount": stats_info.get("source_row_count", ""),
                                "landingrowcount": stats_info.get("bq_row_count", ""),
                                "comparisonstatus": stats_info.get("comparison_status", ""),
                                "rowcountdiff": stats_info.get("row_count_diff", ""),
                                "executionid": run_id,
                                "sourceexectimeinsec": stats_info.get(
                                    "source_execution_time", ""
                                ),
                            }
                        ]
                        comparison_data = pd.DataFrame(row_count_compare_data)
                        log.info(
                            f"Loading comparison data for BigQuery table '{landingdataset}.{landingtable}' into the destination table '{destination_dataset}.{comparison_result_table}'."
                        )
                        load_dataframe_to_bq_table(
                            project_id,
                            destination_dataset,
                            comparison_result_table,
                            comparison_data,
                            log,
                        )
                        # Level 2 Check filter.
                        if (
                            stats_info["comparison_status"] == "Fail"
                            and level2checkflag == "Y"
                            and groupbycolumn is not None
                        ):
                            query_comparison_failed_table(
                                connection,
                                project_id,
                                sourcedatabase,
                                sourceschema,
                                sourcetable,
                                landingdataset,
                                landingtable,
                                bq_level2_check_result_table,
                                source_level2_check_result_table,
                                destination_dataset,
                                groupbycolumn,
                                current_date,
                                date_range,
                                run_id,
                                log,
                            )
        log.info(
            "-------------Execution of the row count comparison script is complete. Please check the logs for errors, if any.-------------------"
        )

    except Exception as error:
        log.exception(f"Error while execution of row_count_comparison script : {error}")
    log.info("Sending all pending logs")
    time.sleep(5)

if __name__ == "__main__":
    main()