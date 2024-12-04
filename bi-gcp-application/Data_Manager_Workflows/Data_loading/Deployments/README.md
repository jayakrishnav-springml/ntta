## Workflow Deployment Script
## deploy_workflows.sh
This Bash script is designed to deploy workflows to Google Cloud Workflows (GCP). It automates the deployment process by deploying multiple workflows found in YAML files within a specified directory.

### Usage

To use this script, follow these steps:

1. **Ensure Required Tools**: Ensure you have the necessary tools installed, including `gcloud`, `jq`, and `sed`.
   
2. **Set Paramater**: Pass your `GCP Project ID`, `Service Account Email` used by GCP workflows, `Region` for the export Stored procedures and `Timeout` limit in seconds for VM instance to shutdown ,when running the script. For example:
   ```bash
   ./deploy_workflows.sh <PROJECT_ID> <SERVICE-ACCOUNT-NAME@PROJECT-ID.iam.gserviceaccount.com> <REGION> <TIMEOUT_IN_SECONDS>
   ```

3. **Define Script Variables**: Edit the script to set the required variables:
   - `parent_dir`: The parent directory containing the workflow YAML files and their configuration files.

4. **Run the Script**: Execute the script:
   ```bash
   ./deploy_workflows.sh <PROJECT_ID> <SERVICE-ACCOUNT-NAME@PROJECT-ID.iam.gserviceaccount.com> <REGION> <TIMEOUT_IN_SECONDS>
   ```

### Script Overview

#### `deploy_workflow()`

This function deploys a single workflow to GCP.

- **Parameters**:
  - `workflow_file`: The path to the workflow YAML file.
  - `workflow_name`: The name of the workflow.
  - `description`: The description of the workflow.
  - `labels`: The labels associated with the workflow.
  - `service_account_email`: The email address of the service account.

#### `replace_yaml_value()`

This function replaces a value in a YAML file.

- **Parameters**:
  - `file`: The path to the YAML file.
  - `key`: The key whose value will be replaced.
  - `value`: The new value.

#### `get_description()`

This function retrieves the description of a workflow from its configuration file.

- **Parameters**:
  - `config_file`: The path to the workflow's configuration JSON file.
  - `filename`: The name of the workflow.

#### `get_labels()`

This function retrieves the labels of a workflow from its configuration file.

- **Parameters**:
  - `config_file`: The path to the workflow's configuration JSON file.
  - `filename`: The name of the workflow.

#### `deploy_workflows_in_directory()`

This function deploys all workflows found in a specified directory.

- **Parameters**:
  - `dir`: The path to the directory containing the workflow files.



### Note

Ensure that the necessary permissions are set for the service account to deploy workflows in your GCP project.


## Cloud Scheduler Deployment Script
## deploy_scheduler.sh
This Bash script automates the deployment of Cloud Scheduler jobs based on configuration stored in a JSON file. It reads the configuration for each workflow from the JSON file and creates or updates Cloud Scheduler jobs accordingly.

## Prerequisites

- [Google Cloud SDK](https://cloud.google.com/sdk)
- [jq](https://stedolan.github.io/jq/): Command-line JSON processor

## Usage

1. Ensure you have Google Cloud SDK installed and configured.

2. Ensure `jq` is installed. 

3. Set up your workflow configurations in a JSON file named `scheduling_config.json`. Each workflow should have a unique identifier (workflow ID), and its corresponding configuration should be stored under this ID in the JSON file.

4. If a particular workflow requires multiple schedules, list them as an array.

   Example of `scheduling_config.json`:
   ```json
    {
        "Data_Loading":[{
            "job_name": "ExcusalDetailReport_Scheduler",
            "schedule": "0 21 1 * *",
            "message_body": "{\"argument\": \"{\\\"instance_id\\\":\\\"<instance_id>\\\", \\\"zone\\\":\\\"<zone>\\\" , \\\"callLogLevel\\\":\\\"LOG_ALL_CALLS\\\"}\"}", 
            "location": "us-central1" ,
            "time_zone": "America/Chicago"
        },
        {
            "job_name": "InvoiceDetail_Tunned_Scheduler",
            "schedule": "0 21 2 * *",
            "message_body": "{\"argument\": \"{\\\"instance_id\\\":\\\"<instance_id>\\\", \\\"zone\\\":\\\"<zone>\\\" , \\\"callLogLevel\\\":\\\"LOG_ALL_CALLS\\\"}\"}", 
            "location": "us-central1" ,
            "time_zone": "America/Chicago"
        }]
    }

   ```

4. Execute the script providing the service account email,VM instance name,VM zone as an argument:

   ```bash
   `sudo chmod +x deploy_scheduler.sh`
   `./deploy_scheduler.sh <YOUR_SERVICE_ACCOUNT_EMAIL> <VM_INSTANCE_NAME> <VM_INSTANCE_ZONE>`
   ```

## Script Overview

1. **deploy_scheduler Function**:
   - Deploys or updates a Cloud Scheduler job.
   - Takes job name, schedule, message body, OIDC service account email, location, workflow ID, and time zone as parameters.
   - Uses `gcloud scheduler` commands to create or update the Cloud Scheduler job.

2. **Main Loop**:
   - Loops through YAML files in the `Parent_Workflows` directory.
   - Reads workflow ID, job name, schedule, message body, location, and time zone from `scheduling_config.json`.
   - Calls the `deploy_scheduler` function for each workflow.

## File Structure

- `deploy_scheduler.sh`: Main Bash script.
- `scheduling_config.json`: JSON file containing workflow configurations.
- `Parent_Workflows/`: Directory containing YAML files of Parents workflows.

