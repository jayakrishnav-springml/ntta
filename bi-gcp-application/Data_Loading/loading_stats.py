import logging
import sys
from google.cloud import bigquery
from datetime import datetime
import json
import pandas as pd
import google.cloud.logging
from google.cloud.logging_v2.handlers import CloudLoggingHandler
import os



def configure_logging(config):
    """
    Configure logging to write logs.

    Args:
        config (dict): Configuration dictionary containing project_id, log_name, labels, and log_level.

    Returns:
        logging.Logger: Logger object configured for data_transfer.
    """
    log = logging.getLogger("data_loading")
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


def get_job_status_and_error(job):
    """
    Returns the error message for the load_job

    Args:
        project_id (str): Project ID of the Google Cloud Platform (GCP) environment.
        dataset_id (str): ID of the destination BigQuery dataset.
        table_id (str): ID of the destination BigQuery table.
        dataframe (pandas.DataFrame): DataFrame to be loaded into the BigQuery table.
    """
    if job.error_result is None and not job.errors:
        return "Success", ""
    elif len(job.errors) < 2:
        return "Fail", job.errors[0].get("message", "")
    elif len(job.errors) == 2:
        return "Fail", job.errors[1].get("message", "")
    else:
        return "Fail", job.errors[2].get("message", "")


def load_dataframe_to_bq_table(project_id, dataset_id, table_id, dataframe, log):
    """
    Load a Pandas DataFrame into a BigQuery table.

    Args:
        project_id (str): Project ID of the Google Cloud Platform (GCP) environment.
        dataset_id (str): ID of the destination BigQuery dataset.
        table_id (str): ID of the destination BigQuery table.
        dataframe (pandas.DataFrame): DataFrame to be loaded into the BigQuery table.
    """
    bq_client = bigquery.Client(project=project_id)

    # Construct the table reference
    table_ref = f"{project_id}.{dataset_id}.{table_id}"

    if not dataframe.empty:
        # Load the DataFrame into the BigQuery table
        bq_client.load_table_from_dataframe(dataframe, table_ref).result()
    else:
        log.info(
            f"The query result is empty, so no data will be inserted into the {table_id} table"
        )
    # Load the DataFrame into the BigQuery table


def list_load_jobs(
    project_id,
    email_id,
    creation_time,
    log,
    bq_dataset_name,
    bq_table_name,
):
    """
    Retrieves the list of load jobs and their details created by the specified email ID within the specified time frame.
    Uploads the statistics of the load jobs to a specified Google Cloud Storage (GCS) bucket and BigQuery (BQ) table.

    Args:
        project_id (str): The project ID of the Google Cloud Platform (GCP) environment.
        email_id (str): The email ID associated with the jobs.
        creation_time (datetime): The starting creation time(UTC) of the jobs.
        log (Logger): The logger object for logging messages.
        bq_dataset_name (str): The name of the BigQuery dataset for loading statistic.
        bq_table_name (str): The name of the BigQuery table for loading statistic.

    Returns:
        list: A list of load jobs matching the specified criteria.
    """
    client = bigquery.Client(project=project_id)
    creation_datetime = datetime.strptime(creation_time, "%Y-%m-%dT%H:%M:%S")
    current_datetime=datetime.now()
    execution_id = get_execution_id(project_id, bq_dataset_name, bq_table_name, log)
    jobs = list(client.list_jobs(all_users=True, min_creation_time=creation_datetime))
    # Filter load jobs for the specified user
    load_jobs = [
        job
        for job in jobs
        if job.job_type == "load"
        and job.user_email == email_id
        and job.job_id.startswith("bqjob")
    ]
    load_job_info = []
    fail_tables_count = 0
    running_jobs_count = 0
    for job in load_jobs:
        if job.state == "DONE":
            output_rows = int(job.output_rows) if job.output_rows is not None else 0
            duration = (job.ended - job.created).total_seconds()
            dataset_name = job.destination.dataset_id
            table_name = job.destination.table_id
            status, error = get_job_status_and_error(job)
            if status == "Fail":
                fail_tables_count += 1

            load_job_info.append(
                [
                    dataset_name,
                    table_name,
                    duration,
                    output_rows,
                    status,
                    job.job_id,
                    error,
                    current_datetime,
                    execution_id,
                ]
            )
        else:
            running_jobs_count += 1
            log.info(
                f"Job_id: {job.job_id} is still running so you can't find the result of this job_id"
            )
    
    # Create DataFrame
    load_details = pd.DataFrame(
        load_job_info,
        columns=[
            "dataset_name",
            "table_name",
            "gcs_to_bq_loading_time_sec",
            "row_count",
            "gcs_to_bq_load_status",
            "bq_job_id",
            "error",
            "load_datetime",
            "execution_id",
        ],
    )

    load_dataframe_to_bq_table(
        project_id, bq_dataset_name, bq_table_name, load_details, log
    )
    log_data = {
        "Total number of tables extracted": len(load_jobs) - running_jobs_count,
        "Total number of tables loaded sucessfully": len(load_jobs)
        - running_jobs_count
        - fail_tables_count,
        "Total number of tables fail to load": fail_tables_count,
        "BQ table name for loading statistics ": bq_dataset_name + "." + bq_table_name,
        "log_type": "data_loading",
    }
    log.info(log_data)

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

def get_execution_id(project_id, bq_dataset_name, bq_table_name, log):
    """
    Retrieve the execution ID from a BigQuery table and increment it with one.

    Parameters:
        project_id (str): The project ID.
        bq_dataset_name (str): The destination dataset name in BigQuery.
        bq_table_name (str): The name of the table in BigQuery.
        log (Logger): The logger object for logging.

    Returns:
        int: The execution ID.

    """
    get_execution_id_query = f"select max(execution_id) as executionid from {bq_dataset_name}.{bq_table_name};"
    log.info(
        f"Query to retrieve execution_id from '{bq_dataset_name}.{bq_table_name}' table in BigQuery using the following query:{get_execution_id_query}."
    )
    bq_execution_id_query_result = get_bigquery_query_result(
        project_id, get_execution_id_query
    )
    execution_id = bq_execution_id_query_result["executionid"].iloc[0]
    if pd.isna(execution_id) or execution_id <= 0:
        return 1
    return int(execution_id) + 1

def main():
    # Check if enough arguments are provided
    if len(sys.argv) < 4:
        print("Not enough arguments provided. Expected 3 arguments: file_path, creation_time, email_id")
        sys.exit(1)
    try:
        file_path = sys.argv[1]
        creation_time = sys.argv[2]
        email_id = sys.argv[3]
        with open(file_path, "r") as config_file:
            config = json.load(config_file) 

        log = configure_logging(config=config)
        log.info("------Getting loading statistics------") 

        project_id = config.get("project_id", "")
        bq_dataset_name = config.get("bq_dataset_name", "")
        bq_table_name = config.get("bq_table_name", "")
        os.environ['GOOGLE_CLOUD_PROJECT'] = project_id
        list_load_jobs(
            project_id,
            email_id,
            creation_time,
            log,
            bq_dataset_name,
            bq_table_name,
        )
        sys.exit(0)
    except ValueError as ve:
        log.error(f"ValueError: {ve}")
        sys.exit(1)
    except Exception as error:
        log.error(f"Error while getting statistics of data loading: {error}")
        sys.exit(1)
        


if __name__ == "__main__":
    main()
