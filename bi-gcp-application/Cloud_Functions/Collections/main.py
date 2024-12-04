import functions_framework
import os
import json
from datetime import datetime
import pytz
from google.cloud import bigquery
from google.cloud import storage
import logging
import google.cloud.logging
from concurrent.futures import ThreadPoolExecutor, as_completed
import time
import uuid

# Setup logging
logging_client = google.cloud.logging.Client()
logging_client.setup_logging()

# Create a logger instance
logger = logging.getLogger(__name__)
logger.setLevel(logging.INFO)

class CollectionsExport:
    def __init__(self, project_id , dataset_id ,bucket_name ,destination_folder_prefix ) -> None:
        """
        Initializes the class with Project ,GCS bucket and dataset details
        Initializes BigQuery and Cloud Storage clients.
        Args:
            project_id (str) : Project ID 
            dataset_id (str): The BigQuery  dataset ID.
            bucket_name (str): The name of the Google Cloud Storage bucket.
            destination_folder_prefix (str): The prefix folder path in the GCS bucket.
        Returns:
            None or Tuple[str, int]: Returns an error message and status code 
            if client initialization fails.
        """
        # Initialize instance variables
        self.project_id =project_id
        self.dataset_id = dataset_id
        self.bucket_name = bucket_name
        self.destination_folder_prefix = destination_folder_prefix
        self.bq_client = bigquery.Client()
        self.storage_client = storage.Client()
        self.timezone_str = "America/Chicago"

    def get_current_year_month(self):
        """
        Returns the current year and month in the specified timezone.
        """
        timezone = pytz.timezone(self.timezone_str)
        chicago_time = datetime.now(timezone)
        return chicago_time.strftime("%Y_%m")  # e.g., "2024_07"
    
    def run_bq_query(self, query):
        """
        Run a query in BigQuery.
        """
        try:
            query_job = self.bq_client.query(query)
            query_job.result()  # Wait for the job to complete
        except Exception as e:
            logger.error(f"Error in run_bq_query {query} : {e}")
            raise e 

    def create_partitioned_table(self, table_id, source_table_id, no_of_partitions):
        """
        Create a partitioned table in BigQuery.
        Args:
            table_id (str) : Partitioned Table to Create 
            source_table_id (str): Source Table to create Partitioned table
            no_of_partitions (str): No of Partitions .
        Returns:
            None 
        """
        qry = f"""
            DECLARE no_of_partitions INT64 DEFAULT {no_of_partitions};
            DECLARE export_uri STRING;
            DECLARE i INT64;
            DROP TABLE IF EXISTS {self.dataset_id}.{table_id};
            CREATE TABLE {self.dataset_id}.{table_id}
            PARTITION BY RANGE_BUCKET(export_id, GENERATE_ARRAY(0, no_of_partitions, 1))
            CLUSTER BY export_id
            AS (
            SELECT *, CAST(FLOOR(no_of_partitions*RAND()) AS INT64) AS export_id
            FROM {source_table_id}
            );
        """
        query_job = self.bq_client.query(qry)
        query_job.result()  # Wait for the job to complete
        logger.info(f"Partitioned table {self.dataset_id}.{table_id} created successfully!")

    def export_table_to_gcs(self,shard_no, table_id, temp_destination_blob_name, export_format="CSV"):
        """
        Exports data from a specific shard of a BigQuery table to a Google Cloud Storage (GCS) bucket.
        This function retrieves data from the specified table based on the provided `shard_no`
        using a WHERE clause. It then exports the filtered data to GCS in the chosen format.

        Args:
            shard_no (int): The shard number to filter and export data for.
            table_id (str): The ID of the BigQuery table to export data from.
            temp_destination_blob_name (str): The desired filename for the exported data in GCS.
            export_format (str, optional): The format for the exported data. Defaults to "CSV".
                Supported formats are "CSV", "JSON", "AVRO", and "PARQUET".
        Returns:
            None
        """
        table_query = f"""
            SELECT * EXCEPT(export_id)
            FROM {self.dataset_id}.{table_id}
            WHERE export_id = {shard_no}
        """
    
        # Create a unique temporary table to store the query results
        partitioned_table_id = f"{self.dataset_id}.temp_{str(uuid.uuid4()).replace('-', '_')}"

        # Define the query job configuration
        job_config = bigquery.QueryJobConfig(destination=f"{self.project_id}.{partitioned_table_id}")

        # Run the query and store the result in the temporary table
        query_job = self.bq_client.query(table_query, job_config=job_config)
        query_job.result()  # Wait for the job to complete
        # Define the destination URI
        destination_uri = f"gs://{self.bucket_name}/{temp_destination_blob_name}"

        # Configure the extract job
        extract_job = self.bq_client.extract_table(
            partitioned_table_id,
            destination_uri,
            job_config=bigquery.ExtractJobConfig(
                destination_format=export_format
            ),
        )

        # Start the extract job and wait for it to complete
        extract_job.result()

        # Clean up the temporary table
        self.bq_client.delete_table(partitioned_table_id)

    def clean_temp_files(self,project_id,export_dataset,temp_files_export_prefix):
        """Clean all temp files and table in case of any errors during GCF execution"""
        try:

            # List all the chunk files
            blobs = list(self.storage_client.list_blobs(self.bucket_name, prefix=temp_files_export_prefix))
            # Delete the chunk files
            for blob in blobs:
                blob.delete()

            # List all temp tables
            query = f"""
                SELECT
                table_name
                FROM
                `{project_id}.{export_dataset}.INFORMATION_SCHEMA.TABLES`
                WHERE
                table_name LIKE 'temp_%'
                """

            query_job = self.bq_client.query(query)
            results = query_job.result()
            #delete all temp tabls
            for row in results:
                self.bq_client.delete_table(project_id+"."+export_dataset+"."+row.table_name)
        except Exception as e:
            logger.error(f"Error in clean_temp_files : {e}")
            raise e
        

    
    def concatenate_files_in_gcs(self, final_blob_name, chunk_blob_name_prefix):
        """
        Concatenate multiple GCS files into one and delete the chunk files.
        """
        bucket = self.storage_client.bucket(self.bucket_name)

        # List all the chunk files
        blobs = list(self.storage_client.list_blobs(self.bucket_name, prefix=chunk_blob_name_prefix))
        if len(blobs) == 0:
            return "No chunk files found.", 404

        # Destination blob
        destination_blob = bucket.blob(final_blob_name)

        # Compose chunks into a single file
        destination_blob.compose(blobs)

        
        # Delete the chunk files
        for blob in blobs:
            blob.delete()
        


    def run_export(self,table_id):
        """
            Runs the export pipeline for Given Table data from BigQuery to GCS.
            Args:
                table_id (str): Bigquery table ID.
            Returns:None
        """
        try:
            no_of_partitions = 10
            logger.info(f"Creating Exports of  : {table_id} with {no_of_partitions} Partitions")
            year_month = self.get_current_year_month()
            export_table_id = f"{self.dataset_id}.{table_id}"
            partitioned_table_id = f"{table_id}_partitioned"
            temp_destination_blob_name = f"{self.destination_folder_prefix}/temp_{str(uuid.uuid4()).replace('-', '_')}/{table_id}"
            final_blob_name = f"{self.destination_folder_prefix}/{year_month}/{table_id}.csv"
            
            self.create_partitioned_table( partitioned_table_id, export_table_id, no_of_partitions)

            with ThreadPoolExecutor(max_workers=no_of_partitions) as executor:
                futures = [
                    executor.submit(self.export_table_to_gcs,shard_no, partitioned_table_id, f"{temp_destination_blob_name}_{shard_no}.csv")
                    for shard_no in range(no_of_partitions)
                ]
                for future in as_completed(futures):
                    try:
                        future.result()
                    except Exception as e:
                        logger.error(f"Error occurred: {e}")
                        raise e
            self.concatenate_files_in_gcs(final_blob_name, temp_destination_blob_name)
        except Exception as e:
            logger.error(f"Error in run_export for Table {table_id} : {e}")
            raise e
        finally:
            self.clean_temp_files(self.project_id,self.dataset_id,temp_destination_blob_name)


    
@functions_framework.http
def collections_exports(request):
    """Responds to HTTP request.
    Args:
        request (flask.Request): HTTP request object.
    Returns:
        The response text or any set of values that can be turned into a
        Response object using
        `make_response <http://flask.pocoo.org/docs/1.0/api/#flask.Flask.make_response>`.
    """
    try:
        data = request.get_json(silent=True)
        if data is None:
            raise ValueError("No JSON payload provided")
        project_id=data.get("project_id")
        bucket_name = data.get("bucket_name")
        export_dataset_id = data.get("export_dataset_id")
        table_Lespam = data.get("table_Lespam")
        table_Cpa = data.get("table_Cpa")
        table_Cmi = data.get("table_Cmi")
        table_Swc = data.get("table_Swc")
        destination_folder_path = data.get("destination_folder_path")
        logger.info(f"Creating Exports in : {destination_folder_path}")

        start_time = time.time()
        
        # Initialize Class Object 
        collectionsexport = CollectionsExport(project_id,export_dataset_id ,bucket_name ,destination_folder_path) 
        
        # Run Both Collections SP to Load Data in Tables for Export 
        stored_procedure_query = "CALL EDW_TRIPS.CollectionsScript();"
        collectionsexport.run_bq_query( stored_procedure_query)
        logger.info(f"CollectionsScript Executed , Data Loaded in Source tables ")
        stored_procedure_query = "CALL EDW_TRIPS.Collections_FileCreationScript();"
        collectionsexport.run_bq_query( stored_procedure_query)
        logger.info(f"Collections_FileCreationScript Executed ,Export tables Created")
        
        # Exporting All 4 tables one by one 
        collectionsexport.run_export(table_Lespam)
        logger.info(f"{table_Lespam} Exported To GCS {destination_folder_path}")
        collectionsexport.run_export(table_Cpa)
        logger.info(f"{table_Cpa} Exported To GCS {destination_folder_path}")
        collectionsexport.run_export(table_Cmi)
        logger.info(f"{table_Cmi} Exported To GCS {destination_folder_path}")
        collectionsexport.run_export(table_Swc)
        logger.info(f"{table_Swc} Exported To GCS {destination_folder_path}")
        
        end_time = time.time()
        
        return "Collections Data has been successfully exported.",200
    except ValueError as ve:
        return ve,400
    except Exception as e:
        return e,500
