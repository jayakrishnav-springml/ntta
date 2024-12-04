import functions_framework
import google.cloud.storage
import google.cloud.bigquery
import zipfile
import io
import pandas as pd
import pytz
from datetime import datetime
import os
from google.cloud import secretmanager
import logging
import google.cloud.logging

client = google.cloud.logging.Client()
client.setup_logging()

logging.basicConfig(level=logging.INFO)



class Bankcruptcy:
    def __init__(self, project_id, bucket_name, input_folder,destination_folder ,stage_dataset_id ,main_dataset_id ,stage_table_id ,main_table_id ,secret_id , version):
        self.project_id  = project_id
        self.bucket_name = bucket_name

        self.storage_client = google.cloud.storage.Client()
        self.bucket = self.storage_client.bucket(self.bucket_name)
        self.bigquery_client = google.cloud.bigquery.Client()

        self.input_folder = input_folder
        self.destination_folder = destination_folder

        self.stage_dataset_id = stage_dataset_id
        self.stage_table_id  = stage_table_id
        self.main_dataset_id  =main_dataset_id
        self.main_table_id = main_table_id

        self.secret_id = secret_id
        self.version = version

    def get_secret(self,project_id,secret_id,version):
        """
        Retrieve a specific version of a secret from Google Cloud Secret Manager.

        Args:
            project_id (str): The ID of the Google Cloud project containing the secret.
            secret_id (str): The ID or name of the secret to retrieve.
            version (str): The version of the secret to access.

        Returns:
            str: The decoded secret value as a string.
        """

        # Construct the secret resource name
        client = secretmanager.SecretManagerServiceClient()
        # Form the full resource name for the secret version
        secret_resource_name = f"projects/{project_id}/secrets/{secret_id}/versions/{version}"
        # Access the secret
        response = client.access_secret_version(name=secret_resource_name)
        # Extract the secret value (payload)
        secret_value = response.payload.data.decode("utf-8")
        return secret_value

    def list_files_in_bucket(self):
        """
        List all files in a specific folder within a Google Cloud Storage bucket.

        Args:
            bucket_name (str): The name of the Google Cloud Storage bucket.
            input_folder (str): The folder path within the bucket to list files from.
        Returns:
            google.cloud.storage.blob.Blob: An iterator of Blob objects representing the files in the specified folder.
        Raises:
            Exception: If there is an error while listing the files in the bucket.
        """
        try: 
             # List all files in the specified folder within the bucket
            blobs = self.bucket.list_blobs(prefix =self.input_folder)
            return blobs
        except Exception as e:
            logging.error(f"Error listing files in bucket {bucket_name}: {str(e)}")
            raise

    def is_zip_file(self,blob):
        return blob.name.endswith('.zip')

    def is_csv_file(self,blob):
        return blob.name.endswith('.csv')

    def add_lnd_update_date(self,dataframe):
        """
            Function to add two columns to a DataFrame:
            1. 'lnd_updatedate': Current datetime in Chicago (CDT) timezone.
            2. 'src_changedate': Column with None values.

            Parameters:
            - dataframe (pd.DataFrame): Input DataFrame to which columns will be added.

            Returns:
            - pd.DataFrame: DataFrame with added columns.
        """
        # Get the current date and time in the Chicago timezone (CDT)
        chicago_tz = pytz.timezone('America/New_York')
        current_datetime = datetime.now(chicago_tz)

        # Convert the datetime object to a naive datetime (without timezone)
        current_datetime_naive = current_datetime.replace(tzinfo=None)
        
        # Add the current datetime to the dataframe
        dataframe['lnd_updatedate'] = pd.to_datetime(current_datetime_naive)
        
        # Add a column with None values
        dataframe['src_changedate'] = None
        
        return dataframe

    def upload_dataframe_to_bigquery(self,dataframe, table_id):
        """
        Uploads a Pandas DataFrame to a BigQuery table.

        Args:
            dataframe (pd.DataFrame): The Pandas DataFrame to upload.
            table_id (str): The fully-qualified ID of the BigQuery table (e.g., 'project_id.dataset_id.table_id').

        Raises:
            Exception: If an error occurs during the upload process.

        Returns:
            None
        """

        try:
           
            # Upload dataframe to BigQuery table
            job_config = google.cloud.bigquery.LoadJobConfig(
                schema=[
            google.cloud.bigquery.SchemaField('lnd_updatedate', google.cloud.bigquery.enums.SqlTypeNames.DATETIME),
            google.cloud.bigquery.SchemaField("src_changedate", google.cloud.bigquery.enums.SqlTypeNames.DATETIME)
                ],
                write_disposition="WRITE_TRUNCATE",
            )
            job = self.bigquery_client.load_table_from_dataframe(dataframe, table_id, job_config=job_config)
            job.result()  # Wait for the job to complete

            logging.info(f"Loaded {job.output_rows} rows into {table_id}.")

        except Exception as e:
            logging.error(f"Error uploading dataframe to BigQuery: {str(e)}")
            raise 
 

    def processing_and_loading(self,dataframe , table_id):
        """
        Processes a DataFrame by adding a 'lnd_updatedate' column and uploads it to a BigQuery table.

        Args:
            dataframe (pd.DataFrame): The input Pandas DataFrame to process and upload.
            table_id (str): The fully-qualified ID of the BigQuery table (e.g., 'project_id.dataset_id.table_id').

        Raises:
            Exception: If an error occurs during the processing or upload process.

        Returns:
            None
        """
        try:
            dataframe = self.add_lnd_update_date(dataframe)
            self.upload_dataframe_to_bigquery(dataframe, table_id)
        except Exception as e:
            logging.error(f"Error in processing and loading dataframe: {str(e)}")
            raise
    
    def move_blob_to_processed_folder(self,blob):
        """
        Moves a Google Cloud Storage blob to a 'processed_files' folder.

        Args:
            blob (google.cloud.storage.blob.Blob): The Google Cloud Storage blob to move.

        Returns:
            google.cloud.storage.blob.Blob: The newly created Blob object in the 'processed_files' folder.
        """
        try:
            # Define the new destination path in the 'processed_files' folder
            new_blob_name = f"{self.destination_folder}/{blob.name.split('/')[-1]}"
            # Create a new Blob object with the new destination path
            new_blob = self.bucket.blob(new_blob_name)
            # Rename/move the original blob to the new destination
            self.bucket.rename_blob(blob, new_blob.name)
            logging.info(f"Moved {blob.name} to {self.destination_folder}")
            return new_blob
        except Exception as e:
            logging.error(f"Error moving file {blob.name} to {self.destination_folder}: {str(e)}")
            raise

    def dataframe_manipluations(self,dataframe):
        """
        Performs manipulations on the columns of a DataFrame:
        1. Removes spaces and underscores from column names.
        2. Converts column names to lowercase.

        Args:
            dataframe (pd.DataFrame): The input Pandas DataFrame to manipulate.

        Returns:
            pd.DataFrame: Manipulated DataFrame with modified column names.
        """
        dataframe.columns = dataframe.columns.str.replace(' ', '').str.replace('_', '')
        dataframe.columns = [f'{col.lower()}' for col in dataframe.columns ]
        return dataframe

    def unzip_and_process_file(self,blob):
        """
        Unzips a file from Google Cloud Storage, processes its contents (CSV or Excel), and uploads to BigQuery.

        Args:
            blob (google.cloud.storage.blob.Blob): The Google Cloud Storage blob to unzip and process.

        Returns:
            None
        """
        try:
        #getting the password
            password = self.get_secret(self.project_id,self.secret_id ,self.version)  

            with io.BytesIO() as file_obj:
                blob.download_to_file(file_obj)
                file_obj.seek(0)

                #Uzip file with passwords
                with zipfile.ZipFile(file_obj, 'r') as zip_ref:
                    zip_ref.setpassword(bytes(password, 'utf-8'))
                    for file_info in zip_ref.infolist():

                        # Unzip file and upload to GCS
                        with zip_ref.open(file_info) as source_file:
                            destination_blob = self.bucket.blob(file_info.filename)
                            destination_blob.upload_from_file(source_file)
                            logging.info (f"Uploaded {file_info.filename} to bucket {self.bucket.name}")

                        #checking if the file is csv and reading the file
                        if file_info.filename.endswith('.csv'):
                            # Read CSV file into a pandas dataframe
                            with zip_ref.open(file_info) as source_file:
                                dataframe = pd.read_csv(source_file)
                                dataframe = self.dataframe_manipluations(dataframe)
                                table_id = f"{self.project_id}.{self.stage_dataset_id}.{self.stage_table_id}"
                                self.processing_and_loading(dataframe ,table_id)
                                logging.info(f"Uploaded {file_info.filename} to BigQuery table {table_id}")

                        #checking if the file is excel and reading the file
                        if file_info.filename.endswith('.xlsx'):
                            with zip_ref.open(file_info) as source_file:
                                dataframe = pd.read_excel(source_file)
                                dataframe = self.dataframe_manipluations(dataframe)
                                table_id = f"{self.project_id}.{self.stage_dataset_id}.{self.stage_table_id}"
                                self.processing_and_loading(dataframe ,table_id)
                                logging.info(f"Uploaded {file_info.filename} to BigQuery table {table_id}")
                        
                        if file_info.filename.endswith('.txt'):
                            with zip_ref.open(file_info) as source_file:
                                logging.info("Reading the TXT file with pipe delimiter")
                                dataframe = pd.read_csv(source_file, delimiter='|')
                                dataframe = self.dataframe_manipluations(dataframe)
                                table_id = f"{self.project_id}.{self.stage_dataset_id}.{self.stage_table_id}"
                                self.processing_and_loading(dataframe ,table_id)
                                logging.info(f"Uploaded {file_info.filename} to BigQuery table {table_id}")
                        self.load_into_main_table()
            # Move the uploaded file to the 'processed_files' folder
            self.move_blob_to_processed_folder(blob)
        except Exception as e:
            logging.error(f"Error unzipping and processing file {blob.name}: {str(e)}")
            raise

    def process_bucket(self):
        """
        Processes files in a Google Cloud Storage bucket:
        1. Lists all files in the bucket.
        2. Checks if each file is a zip file.
        3. If a zip file, unzips and processes its contents.

        Raises:
            Exception: If an error occurs during the processing of files.

        Returns:
            None
        """
        file_count = 0
        try:
            blobs = self.list_files_in_bucket()
            for blob in blobs:
                #Checking if the file is zip file 
                if self.is_zip_file(blob):
                    file_count += 1
                    logging.info(f"File {blob.name} is a zip file. Unzipping and processing...")
                    self.unzip_and_process_file(blob)
            if file_count == 0:
                raise FileNotFoundError("No Zip File Present in the Import Path")
            else:
                logging.info(f"processed {file_count} zip file")
        except Exception as e:
            raise

    def load_into_main_table(self):
        try:
            query = f"Insert into {self.project_id}.{self.main_dataset_id}.{self.main_table_id} select cast( deliveryroutingid as String ) ,  cast (  recordtype as String ) ,  cast ( primarydebtorind as String ) ,  cast (  primaryssn as String ) ,  cast (  primaryfirstname as String ) ,  cast (  primarymiddlename as String ) ,  cast (  primarylastname as String ) ,  cast (  primarysuffixname as String ) ,  cast (  primaryaka1 as String ) ,  cast (  primaryaka2 as String ) ,  cast (  primaryaddress1 as String ) ,  cast (  primaryaddress2 as String ) ,  cast (  primarycity as String ) ,  cast (  primarystate as String ) ,  cast (  primaryzip as String ) ,  cast (  secondarydebtorind as String ) ,  cast (  secondaryssn as String ) ,  cast (  secondaryfirstname as String ) ,  cast (  secondarymiddlename as String ) ,  cast (  secondarylastname as String ) ,  cast (  secondarysuffix as String ) ,  cast (  secondaryaka1 as String ) ,  cast (  secondaryaka2 as String ) ,  cast (  secondaryaddress1 as String ) ,  cast (  secondaryaddress2 as String ) ,  cast (  secondarycity as String ) ,  cast (  secondarystate as String ) ,  cast (  secondaryzip as String ) ,  cast (  filedate as String ) ,  cast (  chapter as String ) ,  cast (  casenumber as String ) ,  cast (  petitionseqnumber as String ) ,  cast (  joint as String ) ,  cast (  prose as String ) ,  cast (  bankruptcycourtnumberlegacy as String ) ,  cast (  bankruptcycourtnumbernew as String ) ,  cast (  courtname as String ) ,  cast (  courtphonenumber as String ) ,  cast (  courtaddress1 as String ) ,  cast (  courtaddress2 as String ) ,  cast (  courtcity as String ) ,  cast (  courtstate as String ) ,  cast (  courtzip as String ) ,  cast (  courtdistrictcode as String ) ,  cast (  courtdivisioncode as String ) ,  cast (  lawfirm as String ) ,  cast (  attorneyname as String ) ,  cast (  attorneyphone as String ) ,  cast (  attorneyaddress1 as String ) ,  cast (  attorneyaddress2 as String ) ,  cast (  attorneycity as String ) ,  cast (  attorneystate as String ) ,  cast (  attorneyzip as String ) ,  cast (  trusteename as String ) ,  cast (  trusteephone as String ) ,  cast (  trusteeaddress1 as String ) ,  cast (  trusteeaddress2 as String ) ,  cast (  trusteecity as String ) ,  cast (  trusteestate as String ) ,  cast (  trusteezip as String ) ,  cast (  `341date` as String ) ,  cast (  accountnumber as String ) ,  cast (  accountnumberdebtorindicator as String ) ,  cast (  filler1 as String ) ,  cast (  filler2 as String ) ,  cast (  accountdateopen as String ) ,  cast (  filler3 as String ) ,  cast (  updatestatus as String ) ,  cast (  changedate as String ) ,  cast (  transfercomments as String ) ,  cast (  datareportingsource as String ) ,  cast (  filler5 as String ) ,  cast (  filler6 as String ) ,  cast (  ediuniquedocumentid as String ) ,  cast (  filler7 as String ) ,  cast (  filler8 as String ) ,  cast (  filler9 as String ) ,   CAST(dateofrecordcreation AS STRING)  ,CAST(lnd_updatedate AS DATETIME)  , cast(Null  as Datetime)from  {self.project_id}.{self.stage_dataset_id}.{self.stage_table_id} WHERE cast(DeliveryRoutingID as int) > 1000 AND CAST(dateofrecordcreation AS STRING) != '' "

            query_job = self.bigquery_client.query(query)
            results = query_job.result()  # Waits for job to complete
            logging.info(f"Query Executed , Data Loaded into main Table")
        except Exception as e:
            # Log the error with details
            logging.error(f"Error in Data Loaded into Main Table.", 500 )# Internal Server Error
            raise  

        
@functions_framework.http
def unzip_files(request):
    try:
        data = request.get_json(silent=True)
        if data is None:
            raise ValueError("No JSON payload provided")
        data = request.get_json(silent=True)
        bucket_name = data.get("bucket_name")
        main_dataset_id = data.get("main_dataset_id")
        secret_id = data.get("secret_id")
        version =data.get("version")
        project_id=data.get("project_id")
        stage_dataset_id= data.get("stage_dataset_id")
        main_table_id = data.get("main_table_id")
        stage_table_id = data.get("stage_table_id")
        input_folder = data.get("input_folder")
        destination_folder = data.get("destination_folder")

        unzip_bankcrupcy = Bankcruptcy(project_id ,
                                    bucket_name ,
                                    input_folder ,
                                    destination_folder ,
                                    stage_dataset_id ,
                                    main_dataset_id,
                                    stage_table_id,
                                    main_table_id,
                                    secret_id,
                                    version)
        unzip_bankcrupcy.process_bucket()
    except FileNotFoundError as fe:
        logging.error(f"Error : {str(fe)}")
        return f"Error in unziping and processing: {str(fe)}", 404  # FILE Not Found
    except Exception as e:
        logging.error(f"Error : {str(e)}")
        return f"Error in unziping and processing: {str(e)}", 500  # Internal Server Error

    return "Processing and loading done successfully", 200  # OK
