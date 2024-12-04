# Extraction Script

This Python script is designed to extract data from a SQL Server / MYSQL database and upload it to Google Cloud Storage (GCS) in CSV format. It operates in a chunked manner to handle large datasets efficiently.

## Project Structure

- **config/LND_TBOS/parallel_LND_TBOS_priority.json**: Configuration file for LND TBOS priority tables.
- **config/EDW_TRIPS/parallel_EDW_TRIPS_static.json**: Configuration file for EDW TRIPS utility, dbo, ref schema static tables and 3 snapshot tables.
- **config/EDW_TRIPS/parallel_EDW_TRIPS_Stage.json**: Configuration file for EDW TRIPS stage tables.
- **config/EDW_TRIPS/parallel_EDW_TRIPS_fact.json**: Configuration file for EDW TRIPS dbo fact tables.
- **config/EDW_TRIPS/parallel_EDW_TRIPS_dim.json**: Configuration file for EDW TRIPS dbo dim tables, Plaza_GIS_Data and Lane_GIS_Data table.
- **config/LND_TBOS/parallel_LND_TBOS_SINGLE.json**: Configuration file for testing with 1 table.
- **config/EDW_TRIPS/parallel_EDW_TRIPS_SINGLE.json**: Configuration file for testing with 1 table.
- **config/LND_TBOS/parallel_LND_TBOS_active_0.json**: old Configuration file for all LND TBOS with active 0(This file is only for reference).
- **config/LND_TBOS/parallel_LND_TBOS_active_1.json**: old Configuration file for all LND TBOS with active 1(This file is only for reference).
- **data_parallel_export_all_tables.py**: The main Python script that processes the data and uploads it to Google Cloud Storage.
- **utility/connection.py**: Utility function to get the connection string and password from secret manager.



## Configuration

The configuration file and list of tables are provided as arguments when executing the data Extraction python script. 
Example of the list of tables - [‘tablename1’,’tablename2’].
If the list of tables parameter is empty ([]), all tables present in the configuration are extracted. Otherwise, only the tables in the list of tables parameter are extracted.


An example configuration file (`config.json`) is provided below:
```json
{
    "connection_string": "Driver=ODBC Driver 17 for SQL Server;Server=10.40.9.26,17001;Database=EDW_TRIPS;Trusted_Connection=yes;",
    "connection_details": {
        "driver": "ODBC Driver 17 for SQL Server",
        "server": "10.40.9.26,17001",
        "database": "EDW_TRIPS",
        "trusted_connection": "yes",
        "encrypt": "no",
        "username": "",
        "password_secret_id": "",
        "secret_version": ""
    },
    "gcs_bucket_name": "prj-ntta-ops-bi-devt-raw-data",
    "database_type": "SQLServer",
    "source_database": "EDW_TRIPS",
    "project_id": "prj-ntta-ops-bi-devt-svc-01",
    "chunk_file_size_gb": 1.0,
    "compression_type": "gzip",
    "parquet_file_page_size_bytes": 1048576,
    "output_folder": "D:\\gcp-data-transfer-csv\\edw_trips_alltables",
    "log_folder_path": "E:\\bcp_logs\\edw_trips_alltables",
    "max_process_count": 10,
    "file_type": ".csv",
    "bq_dataset_map": {
        "LND_TBOS": {
            "dbo": {
                "bq_dataset": "LND_TBOS",
                "table_name_prefix": "dbo_"
            },
            "Finance": {
                "bq_dataset": "LND_TBOS",
                "table_name_prefix": "Finance_"
            },
            "History": {
                "bq_dataset": "LND_TBOS",
                "table_name_prefix": "History_"
            },
            "IOP": {
                "bq_dataset": "LND_TBOS",
                "table_name_prefix": "IOP_"
            },
            "Rbac": {
                "bq_dataset": "LND_TBOS",
                "table_name_prefix": "Rbac_"
            },
            "TER": {
                "bq_dataset": "LND_TBOS",
                "table_name_prefix": "TER_"
            },
            "TranProcessing": {
                "bq_dataset": "LND_TBOS",
                "table_name_prefix": "TranProcessing_"
            },
            "TSA": {
                "bq_dataset": "LND_TBOS",
                "table_name_prefix": "TSA_"
            },
            "Utility": {
                "bq_dataset": "LND_TBOS_SUPPORT",
                "table_name_prefix": ""
            },
            "Reporting": {
                "bq_dataset": "LND_TBOS",
                "table_name_prefix": "Reporting_"
            },
            "docmgr": {
                "bq_dataset": "LND_TBOS",
                "table_name_prefix": "docmgr_"
            }
        },
        "EDW_TRIPS": {
            "dbo": {
                "bq_dataset": "EDW_TRIPS_APS",
                "table_name_prefix": ""
            },
            "Stage": {
                "bq_dataset": "EDW_TRIPS_STAGE",
                "table_name_prefix": ""
            },
            "Ref": {
                "bq_dataset": "EDW_TRIPS_SUPPORT",
                "table_name_prefix": ""
            },
            "Utility": {
                "bq_dataset": "EDW_TRIPS_SUPPORT",
                "table_name_prefix": ""
            }
        }
    },
    "log": {
        "log_level": "INFO",
        "log_name": "data_transfer_log",
        "labels": {}
    },
    "tables": [
    {
            "table_name": "plaza_gis_data",
            "schema_name": "Ref",
            "id_field": "",
            "row_chunk_size": "5000000",
            "chunk_flag": "True",
            "query": "select PlazaID,CONCAT(CHAR(34), REPLACE(REPLACE(REPLACE(Corridor, CHAR(34), '\"\"'), CHAR(147), '\"\"'), CHAR(148),'\"\"'), CHAR(34)) as Corridor,CONCAT(CHAR(34), REPLACE(REPLACE(REPLACE(RoadwayName, CHAR(34), '\"\"'), CHAR(147), '\"\"'), CHAR(148),'\"\"'), CHAR(34)) as RoadwayName,CONCAT(CHAR(34), REPLACE(REPLACE(REPLACE(RoadwayType, CHAR(34), '\"\"'), CHAR(147), '\"\"'), CHAR(148),'\"\"'), CHAR(34)) as RoadwayType,CONCAT(CHAR(34), REPLACE(REPLACE(REPLACE(RoadwayDesc, CHAR(34), '\"\"'), CHAR(147), '\"\"'), CHAR(148),'\"\"'), CHAR(34)) as RoadwayDesc,Status,CONCAT(CHAR(34), REPLACE(REPLACE(REPLACE(Name, CHAR(34), '\"\"'), CHAR(147), '\"\"'), CHAR(148),'\"\"'), CHAR(34)) as Name,CONCAT(CHAR(34), REPLACE(REPLACE(REPLACE(RiteName, CHAR(34), '\"\"'), CHAR(147), '\"\"'), CHAR(148),'\"\"'), CHAR(34)) as RiteName,CONCAT(CHAR(34), REPLACE(REPLACE(REPLACE(Type, CHAR(34), '\"\"'), CHAR(147), '\"\"'), CHAR(148),'\"\"'), CHAR(34)) as Type,TolledLanes,XCoord,YCoord,PostCode,CONCAT(CHAR(34), REPLACE(REPLACE(REPLACE(City, CHAR(34), '\"\"'), CHAR(147), '\"\"'), CHAR(148),'\"\"'), CHAR(34)) as City,CONCAT(CHAR(34), REPLACE(REPLACE(REPLACE(County, CHAR(34), '\"\"'), CHAR(147), '\"\"'), CHAR(148),'\"\"'), CHAR(34)) as County from ref.plaza_gis_data",
            "gcs_upload_flag": "FALSE"
        } 
  ]
}
```

## Configuration Parameters
- connection_string: Connection string to connect to the SQL Server / MYSQL database.
- connection_details: Details to build connection string dynamically in python code.
    - driver: Driver Name.
    - server: Server Name.
    - database: DataBase Name.
    - trusted_connection: Yes for Windows Authentication.
    - encrypt: encrypt value from (yes,no) 
    - username: username for SQL Authentication, else "".
    - password_secret_id: GCP secret manager secret key id where password is stored.
    - secret_version: secret key version.
- gcs_bucket_name: Name of the Google Cloud Storage bucket to upload the Parquet files.
- database_type: Type of the database From SQLServer and MySQL (SQLServer in this case).
- source_database: Name of the source database in Server.
- project_id: Google Cloud Platform project ID.
- chunk_file_size_gb: Size of each chunk file in gigabytes.
- compression_type: Compression type for Parquet files (gzip in this case).
- parquet_file_page_size_bytes: Page size for Parquet files in bytes.
- output_folder: Folder path to store CSV files in System.
- bq_dataset_map: Map object with BQ dataset and table name prefix for LND_TBOS and EDW_TRIPS.
- log_folder_path: Folder path to store log files in System.
- max_process_count: Max threads to run at a particular time.
- file_type: File Extension like - ".csv".
- log: Configuration for logging.
    - log_level: Log level (e.g., INFO, DEBUG, WARNING).
    - log_name: Name of the log.
    - labels: Additional labels for logging.
- tables: List of tables to extract.
    - table_name: Name of the table.
    - schema_name: Name of the schema where the table resides.
    - gcs_upload_flag: Flag to indicate whether to upload the table to GCS (TRUE or FALSE). If flag is True or not present upload to gcs, If False don't upload to GCS.
    - id_field: Field used as an identifier in the table. 
    - row_chunk_size: Size of each row chunk for extraction.
    - query: SQL query to extract data from the table.

The script executes queries to extract table data. If id_field is specified in the configuration file, the script extracts data using id min max chunk approach. Alternatively, if an ID column is not defined in the configuration, the script utilizes a query in configuration file to extract data. 

## Usage
- Ensure you have Python installed on your system. If not install from https://www.python.org/downloads/.
- Install the ODBC driver from Microsoft's website.(https://learn.microsoft.com/en-us/sql/connect/python/pyodbc/step-1-configure-development-environment-for-pyodbc-python-development?view=sql-server-ver16&tabs=windows)
- Install the required Python packages by running:`pip install -r requirements.txt`.
- Add `GOOGLE_APPLICATION_CREDENTIALS` environment variable with value pointing to your service account JSON key file path.
- Set the project ID in cmd to the current project ID.
- prepare the config file based on the table extracted (for example let config file be '.\config\LND_TBOS\parallel_LND_TBOS_SINGLE.json')
- The script will delete the output_folder and log_folder_path folders if they already exist and then create them.
- Run the script using the following command: `python data_parallel_export_all_tables.py .\config\LND_TBOS\parallel_LND_TBOS_SINGLE.json ['plans']`(here config file path changes based on you’re config file path and list of tables changes based on tables to be extracted.)