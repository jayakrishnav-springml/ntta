```markdown
## Workflow Deployment Script

### deploy_workflows.sh
This Bash script automates the deployment of workflows to Google Cloud Workflows (GCP). It processes multiple YAML workflow files in a specified directory and deploys them to GCP.

### Usage

1. **Ensure Required Tools**: Install `gcloud`, `jq`, and `sed`.

2. **Set Parameters**: Pass your `GCP Project ID`, `Service Account Email`, `Region`, `Bucket name` used for exporting files in GCS, and `Timeout` value (in seconds)  for the workflows connection timeout (MAX value is 86400 (~1Day)) when running the script:
   ```bash
   ./deploy_workflows.sh <PROJECT_ID> <SERVICE-ACCOUNT-NAME@PROJECT-ID.iam.gserviceaccount.com> <REGION> <BUCKET_NAME> <TIMEOUT_IN_SECONDS>
   ```

3. **Run the Script**:
   ```bash
   ./deploy_workflows.sh <PROJECT_ID> <SERVICE-ACCOUNT-NAME@PROJECT-ID.iam.gserviceaccount.com> <REGION> <BUCKET_NAME> <TIMEOUT_IN_SECONDS>
   ```

### Script Overview

#### `deploy_workflow()`
Deploys a single workflow to GCP.

- **Parameters**:
  - `workflow_file`: Path to the workflow YAML file.
  - `workflow_name`: Name of the workflow.
  - `description`: Description of the workflow.
  - `labels`: Labels associated with the workflow.
  - `service_account_email`: Email address of the service account.

#### `replace_yaml_value()`
Replaces a value in a YAML file.

- **Parameters**:
  - `file`: Path to the YAML file.
  - `key`: Key whose value will be replaced.
  - `value`: New value.

#### `get_description()`
Retrieves the description of a workflow from its configuration file.

- **Parameters**:
  - `config_file`: Path to the workflow's configuration JSON file.
  - `filename`: Name of the workflow.

#### `get_labels()`
Retrieves the labels of a workflow from its configuration file.

- **Parameters**:
  - `config_file`: Path to the workflow's configuration JSON file.
  - `filename`: Name of the workflow.

#### `deploy_workflows_in_directory()`
Deploys all workflows found in a specified directory.

- **Parameters**:
  - `dir`: Path to the directory containing the workflow files.

### Folder Structure

The script expects the following folder structure:

```
Data_Manager_Workflows/
│
├── 9001/
│   ├── workflow1.yml
│   └── config.json
│
├── 9005/
│   ├── workflow2.yml
│   └── config.json
│
└── ...
```

Each subdirectory contains the workflow YAML file and its corresponding configuration JSON file.

### Note

Ensure the necessary permissions are set for the service account to deploy workflows in your GCP project.

## Cloud Scheduler Deployment Script

### deploy_scheduler.sh
This Bash script automates the deployment of Cloud Scheduler jobs based on configurations stored in a JSON file. It reads the configuration for each workflow from the JSON file and creates or updates Cloud Scheduler jobs accordingly.

### Prerequisites

- [Google Cloud SDK](https://cloud.google.com/sdk)
- [jq](https://stedolan.github.io/jq/): Command-line JSON processor

### Usage

1. **Ensure Google Cloud SDK is installed and configured.**

2. **Ensure `jq` is installed.**

3. **Set up your workflow configurations in a JSON file named `scheduling_config.json`.** Each workflow should have a unique identifier (workflow ID) and its corresponding configuration stored under this ID in the JSON file.

   Example of `scheduling_config.json`:
   ```json
   {
       "workflow_id1": {
           "job_name": "JobName1",
           "schedule": "0 9 * * *",
           "message_body": "{\"argument\": \"{\\\"batchname\\\":\\\"TRIPS_Finance_GL\\\", \\\"fullday_changedata_flag\\\":\\\"N\\\", \\\"callLogLevel\\\":\\\"LOG_ALL_CALLS\\\"}\"}",
           "location": "us-central1",
           "time_zone": "America/New_York"
       },
       "workflow_id2": {
           "job_name": "JobName2",
           "schedule": "0 10 * * *",
           "message_body": "Another message body",
           "location": "us-central1",
           "time_zone": "America/New_York"
       }
       // Add more schedule configurations as needed
   }
   ```

4. **Execute the script providing the service account email as an argument:**
   ```bash
   bash deploy_scheduler.sh YOUR_SERVICE_ACCOUNT_EMAIL
   ```

   Replace `YOUR_SERVICE_ACCOUNT_EMAIL` with the email of the service account to use for the Cloud Scheduler jobs.

### Script Overview

1. **deploy_scheduler Function**:
   - Deploys or updates a Cloud Scheduler job.
   - Takes job name, schedule, message body, OIDC service account email, location, workflow ID, and time zone as parameters.
   - Uses `gcloud scheduler` commands to create or update the Cloud Scheduler job.

2. **Main Loop**:
   - Loops through YAML files in the `Parent_Workflows` directory.
   - Reads workflow ID, job name, schedule, message body, location, and time zone from `scheduling_config.json`.
   - Calls the `deploy_scheduler` function for each workflow.

### File Structure

- `deploy_scheduler.sh`: Main Bash script.
- `scheduling_config.json`: JSON file containing workflow configurations.
- `Parent_Workflows/`: Directory containing YAML files of parent workflows.
```

