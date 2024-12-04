import functions_framework
import google.cloud.storage
import google.cloud.bigquery
import pandas as pd
import pytz
from datetime import datetime
import re
import os
import io
import json
import logging
import openpyxl
import google.cloud.logging

client = google.cloud.logging.Client()
client.setup_logging()
logging.basicConfig(level=logging.INFO)

#1.Returns handles to the storage_client,bucket,bigquery_client
class GCSBigQueryProcessor:
    def __init__(self,project_id, bucket_name, prefix_folder, stage_dataset_id, main_dataset_id, dest_folder):
        """
        Initializes the class with GCS bucket details, folder paths, datasets and initializes BigQuery and Cloud Storage clients.

        Args:
            bucket_name (str): The name of the Google Cloud Storage bucket.
            prefix_folder (str): The source prefix folder path in the GCS bucket.
            stage_dataset_id (str): The BigQuery staging dataset ID.
            main_dataset_id (str) : Bigquery DataSet for Main Table
            dest_folder (str):  The destination/archive folder path in the GCS bucket.
        Returns:
            None or Tuple[str, int]: Returns an error message and status code 
            if client initialization fails.
        """
        # Initialize instance variables
        self.project_id =project_id
        self.bucket_name = bucket_name
        self.prefix_folder = prefix_folder
        self.stage_dataset_id = stage_dataset_id
        self.dest_folder = dest_folder
        self.main_dataset_id = main_dataset_id
        chicago_tz = pytz.timezone('America/Chicago')  
        # Add the formatted datetime as a new column 'lnd_updatedate'
        self.cur_time = datetime.now(chicago_tz).strftime('%Y-%m-%dT%H:%M:%S.%f')
        try:
            # Initialize Google Cloud Storage client and get the bucket
            self.storage_client = google.cloud.storage.Client()
            self.bucket = self.storage_client.bucket(bucket_name)
             # Initialize BigQuery client
            self.bigquery_client = google.cloud.bigquery.Client()
        except Exception as e:
            logging.error(f"Error in Client Initalization: {str(e)}")
            raise 
        
        
    #List all the files in the bucket with prefix folder path
    def list_files_in_bucket(self):
        """
        Lists all files in the specified Google Cloud Storage bucket with a given prefix.
        Returns: A list: A list of Blob objects representing the files in the bucket within the specified prefix.
        """
         # List all blobs in the bucket with the specified prefix
        try:
            return list(self.bucket.list_blobs(prefix = self.prefix_folder))
        except Exception as e:
            logging.error(f"Error listing files in bucket {self.bucket_name}: {str(e)}")
            raise
 
   
    def add_derived_columns(self, dataframe):
        """
        Adds derived columns "lnd_updatedate" to the DataFrame.
        Args: dataframe: The Pandas DataFrame to which columns will be added.
        Returns: DataFrame: Updated Pandas DataFrame with added columns.
        """
        # Get the current date and time in the Chicago timezone (CDT)
        chicago_tz = pytz.timezone('America/Chicago')  
        # Add the formatted datetime as a new column 'lnd_updatedate'
        dataframe['lnd_updatedate'] = datetime.now(chicago_tz).strftime('%Y-%m-%dT%H:%M:%S.%f')
        return dataframe
  
    #Loads data into a BigQuery table after truncating the existing data.
    def load_to_bq(self,df,table_name):
        """
        Loads data into a BigQuery table after truncating the existing data.
        Args: dataFrame : The dataframe with the rows to insert into the table.
             table_name (str): The name of the BigQuery table to insert data into.
        Raises: Exception: If an error occurs during the data loading process
        """
        try:
            # Get a reference to the dataset using the BigQuery client and the dataset ID.
            dataset_ref = self.bigquery_client.dataset(self.stage_dataset_id)
            # Get a reference to the table within the dataset.
            table_ref = dataset_ref.table(table_name)
            # Construct a query to truncate the target table before inserting new data.
            query = f"TRUNCATE TABLE {self.stage_dataset_id}.{table_name} "
            # Execute the query to truncate the table.
            query_job = self.bigquery_client.query(query)
            logging.info(f" {self.stage_dataset_id}.{table_name}  truncated")
            # Insert the new rows from dataframe into the table.
            errors = self.bigquery_client.load_table_from_dataframe(df,table_ref)
            # Check for any errors that occurred during the insertion.
            if not errors:
                logging.info("New rows from dataframe have been added.")
            else:
                # Handle any errors that occurred during insertion by calling a custom error handler.
                logging.info("Error while adding New rows.")
               
        except Exception as e:
            logging.exception(f"Exception occurred during good data insertion of New rows from dataframe: {str(e)}")
            raise

    def process_files(self,pattern, *stage_tables):
        """
        Processes files in a Google Cloud Storage bucket that match a given file pattern.
        Args:pattern (str): The regex pattern to match file names.
             stage_table (str): The BigQuery table where processed data will be loaded.
        Returns: Nothing
        """
        try:
            # List all files in the bucket and filter by the given pattern
            #for blob in self.list_files_in_bucket():
            #    logging.info(blob)
            blobs = [blob for blob in self.list_files_in_bucket() if re.match(pattern, blob.name.split('/')[-1], re.IGNORECASE)]
            logging.info(f"list of blobs/files to process = {blobs}")
            stage_tables_list = [tables for tables in stage_tables]
            logging.info(f"stage_tables_list to load data = {stage_tables_list}")
            for blob in blobs:
                # Download the file as a string and decode it
                input_file_string = blob.download_as_string().decode('unicode_escape')  #blob = blob.decode('utf-8')

                # Read the pipe-delimited String data into a pandas dataframe
                logging.info(f"reading the pipe-delimited input_file_string object")
                list_ACT0002 = []
                list_ACT0010 = []   
                for line in input_file_string.split('\n'):
                                                          
                    if line.startswith(('RACT0002')):
                        list_ACT0002.append(line)
                    elif line.startswith(('RACT0010')):                 # test if it goes to elif statement ..if not just make it IF statement
                        list_ACT0010.append(line)
                if list_ACT0002 == []:
                       print("For sourceFile {input_file}, No matching records fouund for RACT0002") 
                if list_ACT0010 == []:
                       print("For sourceFile {input_file}, No matching records fouund for RACT0010")                        

                df_ACT0002 = pd.DataFrame(list_ACT0002) 
                df_ACT0002 = df_ACT0002[0].str.split('|',expand=True)
                if df_ACT0002.shape[1] == 26:
                    header_row_0002 =['recordtype','submissiondate','pidno','pidshortname','submissionno','recordno','entitytype','entityno','presentmentcurrency','merchantorderno','rdfino','accountno','expirationdate','Amount','Mop','actioncode','authdate','authcode','authresponsecode','traceno','consumercountrycode','Category','Mcc','rejectcode','submissionstatus','null_Column']
                else:
                    header_row_0002 =['recordtype','submissiondate','pidno','pidshortname','submissionno','recordno','entitytype','entityno','presentmentcurrency','merchantorderno','rdfino','accountno','expirationdate','Amount','Mop','actioncode','authdate','authcode','authresponsecode','traceno','consumercountrycode','Category','Mcc','rejectcode','submissionstatus']

                df_ACT0002.columns = header_row_0002
                df_ACT0002 = df_ACT0002.drop('null_Column', axis=1,errors='ignore') # there is a blank NULL column coming after splitting with "|" and hence a dummy column added and dropped to handle it, if it doesnt exist error is suprresed
                
                df_ACT0010 = pd.DataFrame(list_ACT0010) 
                df_ACT0010 = df_ACT0010[0].str.split('|',expand=True)
                if df_ACT0010.shape[1] == 37:
                    header_row_0010=['recordtype',	'submissiondate',	'pidno',	'pidshortname',	'submissionno',	'recordno',	'entitytype',	'entityno',	'presentmentcurrency',	'merchantorderno',	'rdfino',	'accountno',	'expirationdate',	'amount',	'mop',	'actioncode',	'authdate',	'authcode',	'authresponsecode',	'traceno',	'consumercountrycode',	'reserved',	'mcc',	'string_field_23',	'string_field_24',	'string_field_25',	'string_field_26',	'string_field_27',	'string_field_28',	'bool_field_29',	'double_field_30',	'double_field_31',	'double_field_32',	'double_field_33',	'string_field_34',	'string_field_35','null_Column']
                else:
                    header_row_0010=['recordtype',	'submissiondate',	'pidno',	'pidshortname',	'submissionno',	'recordno',	'entitytype',	'entityno',	'presentmentcurrency',	'merchantorderno',	'rdfino',	'accountno',	'expirationdate',	'amount',	'mop',	'actioncode',	'authdate',	'authcode',	'authresponsecode',	'traceno',	'consumercountrycode',	'reserved',	'mcc',	'string_field_23',	'string_field_24',	'string_field_25',	'string_field_26',	'string_field_27',	'string_field_28',	'bool_field_29',	'double_field_30',	'double_field_31',	'double_field_32',	'double_field_33',	'string_field_34',	'string_field_35']
                
                df_ACT0010.columns = header_row_0010
                df_ACT0010 = df_ACT0010.drop('null_Column', axis=1,errors='ignore')   # there is a blank NULL column coming after splitting with "|" and hence a dummy column added and dropped to handle it., if it doesnt exist error is suprresed

                logging.info(f"finished creating dataFranes")
                # Loading into stage table
                for df in (df_ACT0002, df_ACT0010):
                    df = self.add_derived_columns(df)                        # Add derived columns
                    try:
                        # Load the processed data into BigQuery
                        if df.iloc[0,0] == "RACT0002":
                            logging.info(f"working to load : {stage_tables_list[0]}")
                            self.load_to_bq(df,stage_tables_list[0])
                       
                        elif df.iloc[0,0] == "RACT0010":
                            logging.info(f"working to load : {stage_tables_list[1]}")
                            self.load_to_bq(df,stage_tables_list[1])

                        else:
                            logging.info(f"DataFrames df_ACT0002, df_ACT0010 are empty with no RACT0002 or RACT0010 data ")

                    except Exception as e:
                        logging.error(f"Error while loading stage table data to BigQuery or while moving file: {str(e)}")
                        raise 

            #Move the processed file/blob to the 'raw/archive' folder
            self.move_to_archive_folder(blob)
        except Exception as e:
            logging.error(f"Error while processing files with pattern {pattern}: {str(e)}")
            raise
    
    #Moves a blob to the 'raw' folder in Cloud Storage.
    def move_to_archive_folder(self, blob):
        """
        Args: blob (google.cloud.storage.blob.Blob): The blob object to move.
        Returns: google.cloud.storage.blob.Blob: The newly moved blob object.
        """
        try:
            # Construct the new destination path in the 'archive' folder
            archive_blob = self.bucket.blob(f"{self.dest_folder}{blob.name.split('/')[-1]}")
            # Rename the original blob to the new destination
            self.bucket.rename_blob(blob, archive_blob.name)
            logging.info(f"Moved {blob.name} to {self.dest_folder}")
        except Exception as e:
            # Log any errors that occur during the move operation
            logging.error(f"Error while archiving/moving file {blob.name} to {self.dest_folder}: {str(e)}")
            raise

    def log_finish(self):
        logging.info("Processing and loading finished.")
    
    #2.checks if file with the given pattern exists in the storage bucket and then returns True
    def check_files_matching_patterns(self,pattern):
        """
        Args:  patterns (list): A list of regex patterns to match file names against.
        Returns: bool: True if all patterns have at least one match, False otherwise. ie checks if file with the pattern exists in the storage bucket
        """
        # calling the list_files_in_bucket() function
        blobs = self.list_files_in_bucket()
        pattern_match = False
        for blob in blobs:
            blob_name = blob.name.split('/')[-1]
            if re.match(pattern, blob_name, re.IGNORECASE):
                pattern_match = True
        
        # Check if all patterns have a match
        return pattern_match
    
    def load_to_main_tables(self):
          # Run Stored Procedure to Load data from Stage to Main  
            try:
                #query = f"CALL `prj-ntta-ops-bi-snbx-svc-01.CREDIT_CARD_MONITORING.MERGE_Stage_to_Main_Tables`()"
                query = f"Call `{self.project_id}.{self.main_dataset_id}.Credit_Card_Monitoring_Load`()"
                query_job = self.bigquery_client.query(query)
                results = query_job.result()  # Waits for job to complete
                logging.info(f"SP Credit_Card_Monitoring_Load to MERGE_Stage_to_Main_Tables Executed , Data Loaded to Main Tables")
            except Exception as e:
                # Log the error with details
                logging.error(f"Error in SP Credit_Card_Monitoring_Load to MERGE_Stage_to_Main_Tables, Data Loading into main tables ,{str(e)}")
                raise

@functions_framework.http
def CCMonitoring(request):
    """Responds to any HTTP request.
    Args: request (flask.Request): HTTP request object.
    Returns: The response text or any set of values that can be turned into a Response object using
        `make_response <http://flask.pocoo.org/docs/1.0/api/#flask.Flask.make_response>`.
    """
    try:
        data = request.get_json(silent=True)
        bucket_name = data.get("bucket_name")
        prefix_folder = data.get("prefix_folder")
        dest_folder = data.get("dest_folder")
        stage_dataset_id = data.get("stage_dataset_id")
        main_dataset_id = data.get("main_dataset_id")
        project_id = data.get("project_id")
        source_file_pattern =os.environ.get("CCMONITORING_FILE_PATTERN") # dont forget to ADD "CCMONITORING_FILE_PATTERN" = "392529.0000267329*.dfr" to the Environment as env.yaml
        logging.info(source_file_pattern)
        
        logging.info(f" Starting Credit Card Monitoring Import with Specified source_file_pattern_gcs_prefix {source_file_pattern}")

        processor = GCSBigQueryProcessor(project_id,bucket_name, prefix_folder, stage_dataset_id,main_dataset_id ,dest_folder)
        logging.info(f" created processor")
        if processor.check_files_matching_patterns(source_file_pattern):
            processor.process_files(source_file_pattern,"Stage_Exception_Detail_ACT0002","Stage_Deposit_Detail_ACT0010")
            logging.info(f"completed Loading data from files to stage tables")
            processor.load_to_main_tables()
            logging.info(f"completed Loading data from Stage tables to Main tables")

    except Exception as e:
        logging.error(f"Error processing CCMonitoring data: {str(e)}")
        return f"Error processing CCMonitoring data: {str(e)}", 500  # Internal Server Error
        
    return "Processing and loading done successfully", 200  # OK