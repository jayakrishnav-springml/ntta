# Config File Creation Script

This Python script generates a JSON configuration file with table information based on the provided input parameters.


## Arguments

The script takes two arguments:

- A JSON file containing the parameters 
    - tables_list : List of table names to be extracted.(table name should be schema.tablename)
    - id_list : List of ID columns corresponding to the above tables.
    - get_schema_from : "source" if the SQL query needs to be created from the source schema, or "bq" if the SQL query needs to be created for extraction from the BigQuery (BQ) schema.
    
Example parameters json file 
```json
{
    "tables_list": ["dbo.IOPOutboundAndViolationLinking"],
    "id_list": [],
    "get_schema_from": "source"
}
```

- A JSON file to which the generated configuration will be written.
    - Create a new configuration file under the source database folder in the `config` folder.
    - Copy from Existing config file in the folder and make tables list empty.
    - Make the necessary changes to the copied file if required.


## Usage
- Update parametes JSON(config.json) parameters.
- Create new configuration file for Extracting the tables.
- Open cmd and go to the config_scripts folder in Data Extraction.
- Run `python config.py config.json <new config path>` command to genarate tables information in config file.( Example - `python config.py config.json ..\config\EDW_TRIPS\parallel_EDW_TRIPS_SINGLE.json`).
