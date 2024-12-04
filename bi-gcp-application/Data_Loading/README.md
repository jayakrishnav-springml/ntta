# Loading Execution details

## Configuration
The scripts requires a configuration file in JSON format. An example configuration file (config.json) is provided below:
```json
{
    "project_id": "prj-ntta-ops-bi-devt-svc-01",
    "gcs_bucket_name": "prj-ntta-ops-bi-devt-stage-data",
    "gcs_archive_bucket_name":"prj-ntta-ops-bi-devt-archive-data",
    "full_load_dataset_names": [
        "LND_TBOS","LND_TBOS_STAGE_FULL"
    ],
    "partial_load_list": {
        "EDW_TRIPS_APS": [
            "Dim_AccountCategory",
            "Dim_AccountStatusTracker"
        ],
        "LND_TBOS": [
            "IOP_BOS_IOP_OutboundTransactions"
        ]
    },
    "full_load_dataset_flag":"Y",
    "partial_load_flag":"N",
    "log": {
        "log_level": "INFO",
        "log_name": "data_loading",
        "labels": {}
    },
    "bq_dataset_name":"LND_TBOS_SUPPORT",
    "bq_table_name":"Data_Loading_Statistics"
}
```

## Configuration Parameters
- project_id: Google Cloud Platform project ID.
- gcs_bucket_name: Name of the Google Cloud Storage bucket to get the CSV files.
- gcs_archive_bucket_name: Name of the Google Cloud Storage bucket to store archive or load failer files.
- full_load_dataset_names: List of Dataset names(In GCS) that are part of full load(“full load"-All the Tables present under this Dataset folder will be loaded to BQ)
- partial_load_list: A dictionary containing dataset names paired with associated table names. Each dataset name acts as  a key, with its respective value being a list of table names linked to that dataset. (Only the specified table names are loaded into BigQuery.)
- full_load_dataset_flag: A flag indicating whether to execute the full load process for datasets listed in full_load_dataset_names. Set to "Y" to initiate the execution or "N" to skip the execution of datasets mentioned in full_load_dataset_names.
- partial_load_flag:A flag indicating whether to execute the partial load process for datasets in partial_load_list. Set to "Y" to initiate the execution or "N" to skip the execution of datasets mentioned in partial_load_list.
- log (Logger): Configuration for logging.
    - log_level: Log level (e.g., INFO, DEBUG, WARNING).
    - log_name: Name of the log.
    - labels: Additional labels for logging.
- bq_dataset_name (str): The name of the BigQuery dataset for loading statistics.
- bq_table_name (str): The name of the BigQuery table for loading statistics.

## Important Note
- To load all tables within each dataset listed in `full_load_dataset_names`, leave `partial_load_list` empty (`"partial_load_list": {}`) and set `"full_load_dataset_flag"` to "Y".
- To load only the specific tables listed in `partial_load_list`, leave `full_load_dataset_names` empty (`"full_load_dataset_names": []`) and set `"partial_load_flag"` to "Y".


## Prerequisites Before Running the Loading Script

- Ensure that the GCP VM is set up with the required permissions for the service account.
- SSH into the VM and install the following requirements in root directory:
  1. Install `jq` (use `sudo yum install jq` for RedHat-based systems).
  2. Install Python.
  3. Install all the packages listed in the `requirements.txt` file located in the current directory.
- GCP VM metedata should be updated as follows.
    Key: `startup-script-url`
    Value:  `<gcs_path of the startup_script.sh>` ex: `gs://prj-ntta-ops-bi-devt-appconfiguration/Data_Loading_Scripts/startup_script.sh`
- GCP VM should be shutdown.
- A GCP workflow must be deployed as an orchestration tool for data loading, with the necessary permissions configured.

## File Requirements and Execution Order

### File Requirements
- All `.sh`, `.json`, and `.py` files in the current directory must be uploaded to the GCS bucket.

### List of Files and Execution Order

#### `deployment_script.sh`
- This script copies all the necessary files for the data loading process to the GCS bucket.
- During execution, it requires several parameters to be passed as command-line arguments:
  - `<config_file>`
  - `<run_flag>`
  - `<service_account_email>`
  - `<startup_script_bucket_name>`
- The script internally invokes `startup_script.sh`, updating specific parameters dynamically. `deployment_script.sh` will replace placeholders (`<config_file>`, `<run_flag>`, `<service_account_email>`, `<startup_script_bucket_name>`) with actual values in a temporary file.
- After updating the values, the script will:
  - Remove existing files from the GCS path.
  - Upload the latest files from the current directory to the GCS path.
  - Replace the content of the temporary file in the GCS bucket with the filename `startup_script.sh`.
  - Upload all remaining `.sh`, `.json`, and `.py` files to the GCS bucket.
- To apply changes to a configuration file, redeploy by following these steps:
  1. Make the script executable with:
        `sudo chmod +x deployment_script.sh`
  2. Run the script with the necessary parameters:
        `./deployment_script.sh <config_file> <run_flag(Y/N)> <service_account_email> <startup_script_bucket_name>`

     **Example:**
        `./deployment_script.sh ./DEV/config.json Y prj-ntta-bi-compute-sa@prj-ntta-ops-bi-devt-svc-01.iam.gserviceaccount.com prj-ntta-ops-bi-devt-appconfiguration`

### `startup_script.sh`

- This script runs as a startup script on the VM instance. Before triggering the data loading process, ensure that the VM has all required packages/modules and permissions in place.
- The script can be invoked by Workflows either through scheduling or manually.
- It first cleans up the `Data_Loading` directory and copies files from GCS to the `data_loading` directory.
- The script then calls `load.sh` with the following parameters:
  - `<config_file>`
  - `<run_flag>`
  - `<service_account_email>`
  Example:
    `./load.sh ./DEV/config.json Y prj-ntta-i-compute-sa@prj-ntta-ops-evt-svc-01.iam.gserviceaccount.com`
- After executing `load.sh`, the script will shut down the VM.

### `load.sh`

- This script uses configuration details to initiate the load job for tables listed in the config file.
- Depending on the `full_load_dataset_flag` and `partial_load_flag`, it loops through each table and creates a load job.
- The load job runs in synchronous mode, meaning only one job is executed at a time.
- If the load job is successful, the corresponding table files are moved to the archive folder in the `gcs_archive_bucket_name` bucket.
- If the load job fails due to the table not being created in BigQuery, the files remain in the source location.
- For all other failure scenarios, the files are moved to the failed folder in the `gcs_archive_bucket_name` bucket.
- Ensure that all necessary destination datasets and tables are created in BigQuery before running the script.
- After the load job completes and files are moved, the script executes a Python script to collect load statistics and upload these statistics to the `bq_dataset_name`.`bq_table_name` table.
- Execution details are logged to gcp cloud logging.
- The script then executes `loading_stats.py` with the following parameters:
    - `<config_file>`
    - `<utc_datetime>`
    - `<service_account_email>`

### `loading_stats.py`

- This Python script retrieves the loading details initialized by `load.sh` and records the results in a BigQuery table specified in the configuration file.

## Loading Process

### For Scheduled Data Loading

- The Cloud Scheduler triggers the workflows, passing `instance_id` and `zone` as parameters.
- The workflows start the VM instance, which runs the startup script automatically upon booting.
- The data loading process begins on the VM, loading data into BigQuery.
- Once the data loading is complete, the startup script shuts down the VM instance.
- The workflow waits for the VM instance to shut down within the specified timeout period. If the VM does not shut down in time, the workflow will fail; otherwise, it will indicate success.

### For Manual Invocation

- Trigger the workflows directly by providing `instance_id` and `zone` as parameters.
- The remaining process is the same as for Scheduled Data Loading.

### Important Note
- If any errors occur during script execution, the script will exit immediately, and the VM will not be shut down. The workflow will monitor the VM's shutdown status, and if the VM does not shut down within the specified timeout limit, the workflow will report an error.