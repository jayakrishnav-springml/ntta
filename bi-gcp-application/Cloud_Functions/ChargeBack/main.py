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

class GCSBigQueryProcessor:
    def __init__(self,project_id, bucket_name, prefix_folder, stage_dataset_id,bad_dataset_id, main_dataset_id,dest_folder , export_file_prefix):
        """
        Initializes the class with GCS bucket details, folder paths, datasets, 
        and initializes BigQuery and Cloud Storage clients.

        Args:
            bucket_name (str): The name of the Google Cloud Storage bucket.
            prefix_folder (str): The prefix folder path in the GCS bucket.
            stage_dataset_id (str): The BigQuery staging dataset ID.
            bad_dataset_id (str): The BigQuery bad dataset ID.
            main_dataset_id (str) : Bigquery DataSet for Main Table
            dest_folder (str): The destination folder path in the GCS bucket.
            export_file_prefix (str) : Export File Name Prefix
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
        self.bad_dataset_id = bad_dataset_id
        self.main_dataset_id = main_dataset_id
        self.export_file_prefix = export_file_prefix
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

        Returns:
            list: A list of Blob objects representing the files in the bucket with the specified prefix.
        """
         # List all blobs in the bucket with the specified prefix
        try:
            return list(self.bucket.list_blobs(prefix = self.prefix_folder))
        except Exception as e:
            logging.error(f"Error listing files in bucket {self.bucket_name}: {str(e)}")
            raise
    

    def drop_columns(self,data, columns):
        """
        Drops specified columns from each entry in a list of dictionaries.

        Args:
            data (list of dict): The list of dictionaries where columns will be dropped.
            columns (list of str): The list of column names to drop from each dictionary entry.

        Returns:
            list of dict: Updated list of dictionaries with specified columns removed.
        """
        for entry in data:
            for col in columns:
                if col in entry:
                    del entry[col]
        return data

    def add_column(self,data, index, column_name, value):
        """
        Adds a new column with a specified value to a dictionary within a list of dictionaries.

        If the column already exists for the specified index, appends the value to the existing list.

        Args:
            data (list of dict): The list of dictionaries where the column will be added.
            index (int): The index of the dictionary in `data` to which the column will be added.
            column_name (str): The name of the column to add or update.
            value (any): The value to append to the column.

        Returns:
            list of dict: Updated list of dictionaries with the added or updated column.
        """
        if column_name not in data[index]:
            data[index][column_name] = []
        data[index][column_name].append(value)
        return data
    
    def convert_lists_to_strings(self,data):
        """
        Converts list values within dictionaries in a list to comma-separated strings.

        Args:
            data (list of dict): The list of dictionaries where list values will be converted.

        Returns:
            list of dict: Updated list of dictionaries with list values converted to strings.
        """
        for row in data:
            for key, value in row.items():
                if isinstance(value, list):
                    row[key] = ', '.join(value)
        return data

    def identify_and_format_date_column(self, dataframe):
        """
        Identify columns containing date values in string format ('object' dtype),
        convert them to datetime objects, and format them into '%Y-%m-%dT%H:%M:%S.%f' format.

        Args:
            dataframe (pd.DataFrame): The Pandas DataFrame to process.

        Returns:
            pd.DataFrame: Updated Pandas DataFrame with formatted date columns.
        """
        date_columns = []
        for column in dataframe.columns:
            try:
                # Check if the column contains 'object' type (usually strings)
                if dataframe[column].dtype == 'object':  
                    pd.to_datetime(dataframe[column], format='%m/%d/%Y')
                    date_columns.append(column)
            except ValueError:
                continue
        # Process each identified date column
        for column in date_columns:
            dataframe[column] = pd.to_datetime(dataframe[column], format='%m/%d/%Y')
            dataframe[column] = dataframe[column].dt.strftime('%Y-%m-%dT%H:%M:%S.%f')
        
        return dataframe
    
   
    def add_derived_columns(self, dataframe):
        """
        Adds derived columns to the DataFrame.

        Args:
            dataframe (pd.DataFrame): The Pandas DataFrame to which columns will be added.

        Returns:
            pd.DataFrame: Updated Pandas DataFrame with added columns.
        """
        # Get the current date and time in the Chicago timezone (CDT)
        chicago_tz = pytz.timezone('America/Chicago')  
        # Add the formatted datetime as a new column 'lnd_updatedate'
        dataframe['lnd_updatedate'] = datetime.now(chicago_tz).strftime('%Y-%m-%dT%H:%M:%S.%f')
        return dataframe
  
    def handle_insertion_errors(self,errors ,rows_to_insert,bad_table ):
        """
            Handles errors encountered while inserting rows into BigQuery.

            Args:
                errors (list): List of errors returned by the BigQuery insert_rows_json method.
                rows_to_insert (list): List of rows (as dictionaries) that were attempted to be inserted.
                bad_table (str): The name of the BigQuery table where bad rows will be logged.

            Raises:
                None
        """
        try:
            logging.info(f"Encountered errors while inserting rows")
            # Create a copy of the rows to insert for further processing
            bad_rows = rows_to_insert.copy()
            error_map = {}

            # Process each error and map it to the corresponding row index
            for error in errors:
                row_index = error['index']
                if row_index not in error_map:
                    error_map[row_index] = {'errorcolumn': [], 'errorcode': []}
                for err in error['errors']:
                    location = err.get('location', '')
                    message = err.get('message', '')
                    error_map[row_index]['errorcolumn'].append(location)
                    error_map[row_index]['errorcode'].append(message)
            
            # Add error details to the bad rows
            for row_index, error_details in error_map.items():
                bad_rows = self.add_column(bad_rows, row_index, 'errorcolumn', ', '.join(error_details['errorcolumn']))
                bad_rows = self.add_column(bad_rows, row_index, 'errorcode', ', '.join(error_details['errorcode']))

            # Convert lists to strings for insertion into BigQuery
            bad_rows = self.convert_lists_to_strings(bad_rows)
            logging.info("Bad rows prepared for insertion")

            # Remove columns with errors from bad rows
            error_columns = [col for details in error_map.values() for col in details['errorcolumn']]
            bad_rows = self.drop_columns(bad_rows, error_columns)
            # Insert bad rows into the bad table
            table_ref_bad = self.bigquery_client.dataset(self.bad_dataset_id).table(bad_table)
            err1 = self.bigquery_client.insert_rows_json(table_ref_bad, bad_rows)
            logging.info("Errors inserting into bad table")
            
        except Exception as e:
            logging.error(f"Error handling insertion errors: {str(e)}")
            raise

    def load_to_bq(self,table_name, bad_table,rows_to_insert):
        """
        Loads data into a BigQuery table after truncating the existing data.

        Args:
            table_name (str): The name of the BigQuery table to insert data into.
            bad_table (str): The name of the BigQuery table to log bad data in case of insertion errors.
            rows_to_insert (list): The list of rows (as dictionaries) to insert into the table.

        Raises:
            Exception: If an error occurs during the data loading process.
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

            # Insert the new rows into the table.
            errors = self.bigquery_client.insert_rows_json(table_ref, rows_to_insert)

            # Check for any errors that occurred during the insertion.
            if not errors:
                logging.info("New rows have been added.")
            else:
                # Handle any errors that occurred during insertion by calling a custom error handler.
                self.handle_insertion_errors(errors, rows_to_insert,bad_table)
               
        except Exception as e:
            logging.exception(f"Exception occurred during good data insertion: {str(e)}")
            raise

    def process_files(self, pattern, stage_table, bad_data_table=None, custom_transform=None ):
        """
        Processes files in a Google Cloud Storage bucket that match a given pattern.

        Args:
            pattern (str): The regex pattern to match file names.
            stage_table (str): The BigQuery table where processed data will be loaded.
            bad_data_table (str, optional): The BigQuery table where bad data will be loaded. Defaults to None.
            custom_transform (function, optional): A custom transformation function to apply to the dataframe. Defaults to None.

        Returns:
            None
        """
        try:
            # List all files in the bucket and filter by the given pattern
            blobs = [blob for blob in self.list_files_in_bucket() if re.match(pattern, blob.name.split('/')[-1], re.IGNORECASE)]
            
            for blob in blobs:
                # Download the file as a string and decode it
                data = blob.download_as_string().decode('unicode_escape')

                # Read the CSV data into a pandas dataframe
                logging.info(f"reading the csv")
                dataframe = pd.read_csv(io.StringIO(data))

                # Identify and format the date column in the dataframe
                dataframe =self.identify_and_format_date_column(dataframe)

                # Drop rows with missing values in the 'Monthid' column
                dataframe=dataframe.dropna(subset=['Monthid'])

                # Clean column names by removing spaces and converting to lowercase
                dataframe.columns = dataframe.columns.str.replace(' ', '').str.replace('_', '')

                matching_columns = [col for col in dataframe.columns if col.lower() == "datecase#approved".lower()]
                if  matching_columns:
                    actual_old_column_name = matching_columns[0]
                    dataframe = dataframe.rename(columns={actual_old_column_name: "date_case_approved"})

                matching_columns = [col for col in dataframe.columns if col.lower() == "ChaseSequenceNumber".lower()]
                if  matching_columns:
                    actual_old_column_name = matching_columns[0]
                    dataframe = dataframe.rename(columns={actual_old_column_name: "SequenceNumber"})
                
                matching_columns = [col for col in dataframe.columns if col.lower() == "Win-LostSupervisorReview".lower()]
                if  matching_columns:
                    actual_old_column_name = matching_columns[0]
                    dataframe = dataframe.rename(columns={actual_old_column_name: "WinLostSupervisorReview"})
                # Identify columns to drop if they exist
                columns_to_drop = [col for col in ['OriginalDisputeType','UpdatedDisputeType'] if col in dataframe.columns]
                if columns_to_drop:
                    dataframe=dataframe.drop(columns=['OriginalDisputeType','UpdatedDisputeType'])

                # Apply custom transformation if provided, else add derived columns
                if custom_transform:
                    dataframe = custom_transform(dataframe)
                else:
                    dataframe = self.add_derived_columns(dataframe)

                # Convert the dataframe to JSON format and then to a list of dictionaries
                dataframe_to_json= dataframe.to_json(orient= 'records') 
                dataframe_to_dict = json.loads(dataframe_to_json)
                
                try:
                    # Load the processed data into BigQuery
                    self.load_to_bq(stage_table,bad_data_table,dataframe_to_dict)

                    # Move the processed file to the 'raw' folder
                    self.move_to_raw_folder(blob)
                except Exception as e:
                    logging.error(f"Error while loading data to BigQuery or moving file: {str(e)}")
                    raise
        except Exception as e:
            logging.error(f"Error while processing files with pattern {pattern}: {str(e)}")
            raise
    
    def custom_transform_amex(self, dataframe):
        """
        Custom transformation method specific to AMEX and ChargedBack received data.

        Args:
            dataframe (pd.DataFrame): The Pandas DataFrame to transform.

        Returns:
            pd.DataFrame: Transformed Pandas DataFrame with derived columns added.
        """
        return self.add_derived_columns(dataframe)

    def custom_transform_cb_tracking(self, dataframe):
        """
        Custom transformation method specific to CB Tracking data.

        Args:
            dataframe (pd.DataFrame): The Pandas DataFrame to transform.

        Returns:
            pd.DataFrame: Transformed Pandas DataFrame with derived columns added and specific replacements.
        """
        dataframe = self.add_derived_columns(dataframe)
        dataframe['AmountDisputed'] = dataframe['AmountDisputed'].str.replace("á", " ")
        dataframe['TransactionDate'] = dataframe['TransactionDate'].str.replace("á", " ")
        return dataframe

    def move_to_raw_folder(self, blob):
        """
        Moves a blob to the 'raw' folder in Cloud Storage.

        Args:
            blob (google.cloud.storage.blob.Blob): The blob object to move.

        Returns:
            google.cloud.storage.blob.Blob: The newly moved blob object.
        """
        try:
            # Construct the new destination path in the 'raw' folder
            raw_blob = self.bucket.blob(f"{self.dest_folder}{blob.name.split('/')[-1]}")
             # Rename the original blob to the new destination
            self.bucket.rename_blob(blob, raw_blob.name)
            logging.info(f"Moved {blob.name} to {self.dest_folder}")
        except Exception as e:
            # Log any errors that occur during the move operation
            logging.error(f"Error moving file {blob.name} to {self.dest_folder}: {str(e)}")
            raise

    def log_finish(self):
        logging.info("Processing and loading finished.")
    
    

    def create_excel_and_upload(self,project_id,stage_dataset_id,main_dataset_id):
        """
        Creates an Excel workbook containing data from specified BigQuery tables and uploads it to Google Cloud Storage.

        Args:
            project_id (str): The Google Cloud project ID.
            stage_dataset_id (str): The dataset ID where staging tables are located.
            main_dataset_id (str): The main dataset ID where the export tables are located.

        Returns:
            str: Success message if upload is successful.

        Raises:
            Exception: If an error occurs during data processing or upload.
        """
        export_dataset_name = "FILES_EXPORT" 
        # Define table names in TestDB dataset
        table_names = ["AMEX_Matched_to_CTW", "AMEX_Not_Matched_to_CTW","Chase_PDE0020_Matched_To_CTW", "Chase_PDE0020_NonMatched_to_CTW",  "TRIPS_Matched_TO_CTW"]

        # Run Export Sp to Load data to Export Tables based on ChargeBack Queries 
        try:
            query = f"Call `{project_id}.LND_TBOS_SUPPORT.ChargeBack_Export`('{stage_dataset_id}' , '{main_dataset_id}')"
            #query = f"Call `{project_id}.{export_dataset_name}.ChargeBack_Export`()"
            query_job = self.bigquery_client.query(query)
            results = query_job.result()  # Waits for job to complete
            logging.info(f"Sp Executed , Data Loaded in Export Tables")
        except Exception as e:
            # Log the error with details
            logging.error(f"Error in Data Loaded into Export Tables: {str(e)}")
            raise


        # Create a new workbook
        workbook = openpyxl.Workbook()
        if workbook.active is not None:
            del workbook[workbook.active.title]
        # Iterate through each table name
        for table_name in table_names:
            try:
                # Construct BigQuery query to fetch data
                query = f"SELECT * FROM `{project_id}.{export_dataset_name}.{table_name}`"

                # Execute the query and get results
                query_job =self.bigquery_client.query(query)
                results = query_job.result()  # Waits for job to complete

                sheet_name = table_name.replace('_',' ')
                # Create a new sheet for the current table
                sheet = workbook.create_sheet(title=sheet_name)

                # Write table headers to the sheet
                row_data = [field.name for field in results.schema]
                sheet.append(row_data)

                # Write data rows to the sheet
                for row in results:
                    # Convert values to strings before appending
                    sheet.append([str(val) if val is not None else "" for val in row])
            except Exception as e:
                # Log the error with details
                logging.error(f"Error processing table {table_name}: {str(e)}")
                raise
                
        # Informative log at successful completion
        logging.info("Data export to Excel ")



        # Save the workbook as an Excel file in memory
        with io.BytesIO() as buffer:
            workbook.save(buffer)
            excel_data = buffer.getvalue()

        # Create a GCS blob object with a descriptive filename
        blob = self.storage_client.bucket(self.bucket_name).blob(f"Exports/ChargeBack/{self.cur_time[:7]}/{self.export_file_prefix}_{self.cur_time}.xlsx")

        # Upload the Excel file data to the blob
        try:
            blob.upload_from_string(excel_data)
        except Exception as e:
            logging.error(f"Error uploading Excel file to GCS: {str(e)}")
            raise

        logging.info( f"Data successfully exported to Excel and uploaded to {self.bucket_name}")
    
    def check_files_matching_patterns(self,patterns):
        """
        Check if files in a bucket match given patterns.

        Args:
            patterns (list): A list of regex patterns to match file names against.

        Returns:
            bool: True if all patterns have at least one match, False otherwise.
        """
        blobs = self.list_files_in_bucket()
        
        # Initialize a dictionary to track pattern matches
        pattern_matches = {pattern: False for pattern in patterns}
        
        for blob in blobs:
            blob_name = blob.name.split('/')[-1]
            for pattern in patterns:
                if re.match(pattern, blob_name, re.IGNORECASE):
                    pattern_matches[pattern] = True
        
        # Check if all patterns have a match
        return all(pattern_matches.values())
    def load_to_main_tables(self):
          # Run SP to Load data from Stage to Main  
            try:
                query = f"Call `{self.project_id}.LND_TBOS_SUPPORT.ChargeBack_StageToMain`('{self.stage_dataset_id}' , '{self.main_dataset_id}')"
                query_job = self.bigquery_client.query(query)
                results = query_job.result()  # Waits for job to complete
                logging.info(f"Sp Executed , Data Loaded to Main Tables")
            except Exception as e:
                # Log the error with details
                logging.error(f"Error in Data Loading into main tables ,{str(e)}")
                raise



@functions_framework.http
def charge_back(request):
    """Responds to any HTTP request.
    Args:
        request (flask.Request): HTTP request object.
    Returns:
        The response text or any set of values that can be turned into a
        Response object using
        `make_response <http://flask.pocoo.org/docs/1.0/api/#flask.Flask.make_response>`.
    """
    try:
        data = request.get_json(silent=True)
        bucket_name =data.get("bucket_name")
        prefix_folder = data.get("prefix_folder")
        dest_folder = data.get("dest_folder")
        stage_dataset_id = data.get("stage_dataset_id")
        bad_dataset_id =data.get("bad_dataset_id")
        main_dataset_id = data.get("main_dataset_id")
        project_id =data.get("project_id")
        amex_file_pattern = os.environ.get("AMEX_FILE_PATTERN", "AMEX*.*")
        tracking_file_pattern = os.environ.get("TRACKING_FILE_PATTERN", "ChargeBack*.*")
        received_file_pattern = os.environ.get("RECEIVED_FILE_PATTERN", "PDE*.*")
        export_file_name_prefix = os.environ.get("EXPORT_FILE_NAME_PREFIX" , "Final_Output_Reconciliation_File_Amex&Chase")
        
        patterns = [amex_file_pattern, tracking_file_pattern, received_file_pattern]
        logging.info(f" Starting ChargeBack Import with Specified patterns {patterns}")

        processor = GCSBigQueryProcessor(project_id,bucket_name, prefix_folder, stage_dataset_id,bad_dataset_id,main_dataset_id ,dest_folder ,export_file_name_prefix )

        if processor.check_files_matching_patterns(patterns):
        

            processor.process_files(pattern=amex_file_pattern , 
                                    stage_table='dbo_ChargeBack_AMEX',  
                                    bad_data_table='dbo_CB_Amex_BadData', 
                                    custom_transform=processor.custom_transform_amex)

            processor.process_files(pattern=received_file_pattern, 
                                    stage_table='dbo_ChargeBack_Received', 
                                    bad_data_table='dbo_CB_Received_BadData',
                                    custom_transform=processor.custom_transform_amex,
                                    )

            processor.process_files(pattern=tracking_file_pattern, 
                                    stage_table='dbo_ChargeBack_Tracking', 
                                    bad_data_table='dbo_CB_Tracking_BadData', 
                                    custom_transform=processor.custom_transform_cb_tracking)

            processor.create_excel_and_upload(project_id,stage_dataset_id,main_dataset_id)

            processor.load_to_main_tables()
              
            return "Success"
        else :
            return "All three files: chargeback_tracking, chargeback_amex, and chargeback_received, are not present in the bucket. Halting the process" , 404
    except Exception as e:
        logging.error(f"Error processing charge back data: {str(e)}")
        return f"Error processing charge back data: {str(e)}", 500  # Internal Server Error
    
