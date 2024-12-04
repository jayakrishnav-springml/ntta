# Row Count Comparsion Script

This Python script facilitates the comparison of row counts between a source server and BigQuery. It records the comparison results in a BigQuery table. In case of comparison failures,level2checkflag is set to "Y" and groupbycolumn is not null, it executes queries on both the source and destination, recording the results in separate tables as configured in the configuration file.

## Configuration

The script requires a configuration file in JSON format. An example configuration file (config.json) is provided below:
```json
{
    "project_id": "prj-ntta-ops-bi-devt-svc-01",
    "date_range":30,
    "tables_list_info":{
        "dataset_name":"LND_TBOS_SUPPORT",
        "table_name":"Landing_Vs_Source_Comparison_Config",
        "comparisonrunflag":"Y"
    },
    "destination_table_info":{
        "destination_dataset":"LND_TBOS_SUPPORT",
        "comparison_result_table":"Landing_VS_Source_Comparison",
        "bq_level2_check_result_table":"Landing_DailyRowCount",
        "source_level2_check_result_table":"Source_DailyRowCount"
    },
    "log": {
        "log_level": "INFO",
        "log_name": "src_vs_bq_row_comparison",
        "labels": {}
    },
    "connection_details": [{
        "driver": "ODBC Driver 18 for SQL Server",
        "server": "nprodtboslstr03",
        "database": "IPS",
        "trusted_connection": "yes",
        "encrypt": "no"
    },
    {
        "driver": "ODBC Driver 18 for SQL Server",
        "server": "nprodtboslstr06",
        "database": "TBOS",
        "trusted_connection": "yes",
        "encrypt": "no"
    }
]
    
}
```
## Configuration Parameters

- project_id: The Google Cloud Platform (GCP) project ID.
- date_range: This specifies that the filter is used to retrieve data from only the specified number of days in the past from the current date.
- tables_list_info: The BigQuery table contains details of the table and schema names that need to be compared by the script
    - dataset_name: The dataset_name parameter specifies the BigQuery dataset name where the tables for row count comparison are located.
    - table_name: The table_name parameter specifies the BigQuery table name from which the table names will be fetched to perform the row count comparison.
    - comparisonrunflag(str): Flag for selecting the tables names from tables_list_info.table_name
- destination_table_info: Information about the BigQuery dataset and tables to store comparison results.
    - bq_comparision_failure_table: The result of the query executed on BigQuery for comparison failed tables
    - source_comparision_failure_table: The result of the query executed on source server for comparison failed tables
- log: Logging configuration, including log level, log name, and labels.
- connection_details: List of connection details for multiple databases. Each database connection is used to perform level 1 and level 2 checks only for the tables specific to that particular database. For example, if connection_details include two databases, TBOS and IPS, then TBOS connection details are used to compare only the tables that have TBOS as the source database in the config table GBQ.

## Configuration Table in GBQ:

### Table Name: `LND_TBOS_SUPPORT.Landing_Vs_Source_Comparison_Config`

- sourcedatabase: Name of the source database.
- sourceschema: Schema of the source table.
- sourcetable: Name of the source table.
- keycolumn: Name of the ID column.
- landingdataset: Name of the landing dataset.
- landingtable: Name of the landing table.
- comparisonrunflag: Flag indicating whether the table needs to be compared.
- level2checkflag: Flag indicating whether the table should undergo a Level 2 check.
- groupbycolumn: Column name used for the GROUP BY clause in Level 2 checks.

## Important Note

- Ensure that all the required destination datasets and tables are created in BigQuery before executing the script.
- Make sure that the values in `tables_list_info` and `destination_table_info` are accurate, and verify that the value for `comparisonrunflag` is correct. Based on the status of this flag, the table names will be fetched accordingly.
- Level 2 Check will be performed for tables that meet the following criteria: they have a row count difference from Level 1, the `level2checkflag` is set to "Y", and the `groupbycolumn` value is not Null in the `Landing_Vs_Source_Comparison_Config` table in GBQ.
- To Execute the script ensure utility folder is present in Data Extraction Folder.
- For each table undergoing row comparison, the `keycolumn` must be of INTEGER type.
- IF date_range<=0 then date_range filter won't be applied.

## Usage

- Ensure you have Python installed on your system. If not install from https://www.python.org/downloads/.
- Install the ODBC driver from Microsoft's website.(https://learn.microsoft.com/en-us/sql/connect/python/pyodbc/step-1-configure-development-environment-for-pyodbc-python-development?view=sql-server-ver16&tabs=windows)
- Install the required Python packages by running:`pip install -r requirements.txt`.
- Run the setup.py script in Data Extraction Folder to specify dependencies: `python setup.py install`
- Run the script using the following command: `python comparision_script.py comparision_config.json`

