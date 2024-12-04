# README

## Overview
This script automates the creation and updating of notification channels and alert policies in Google Cloud Monitoring. It ensures that specified email addresses are set up as notification channels and that alert policies are created or updated accordingly.

## Prerequisites
- Ensure you have the Google Cloud SDK installed and authenticated.
- You need the `jq` utility installed for parsing JSON files.
- Ensure you have the required permissions to create and update monitoring channels and policies in the specified project.

## Usage
Run the script with the following command:
```bash
./deploy_alerts.sh <PROJECT_ID>
```
Replace `<PROJECT_ID>` with your actual Google Cloud project ID.

## Script Explanation

### Notification Channels
1. **Define Notification Channels**:
    ```bash
    notification_channels=(
      "vvishnubhatla@ntta.org"
      ...
      # Add more email addresses here if needed
    )
    ```

2. **Check Project ID**:
    ```bash
    if [ -z "$1" ]; then
        echo "Warning: project ID not passed as parameter. Please provide project ID as shown below."
        echo "./deploy_alerts.sh <PROJECT_ID>"
        exit 1
    fi
    project_id="$1"
    ```

3. **Retrieve Existing Notification Channels**:
    ```bash
    existing_channels=$(gcloud alpha monitoring channels list --project="$project_id" --format="value(name,labels.email_address)")
    ```

4. **Create or Retrieve Notification Channels**:
    The script checks if each email address in `notification_channels` already exists. If not, it creates a new notification channel.

5. **Store Channel IDs**:
    The script stores the channel IDs of both existing and newly created channels in an array `notification_channel_ids`.

### Alert Policies
1. **Retrieve Existing Alerts**:
    ```bash
    existing_alerts=$(gcloud alpha monitoring policies list --project="$project_id" --format="value(displayName)")
    ```

2. **Read JSON Files**:
    The script reads all JSON files in the current directory and extracts the `displayName` to identify the alerts.

3. **Create or Update Alerts**:
    The script checks if each alert policy already exists based on the `displayName`. If it exists, it updates the alert; otherwise, it creates a new alert policy.

## Adding More Email Addresses
To add more email addresses to the notification channels, simply add them to the `notification_channels` array:
```bash
notification_channels=(
  "newemail@domain.com"
  ...
)
```

## Example
```bash
./deploy_alerts.sh my-gcp-project
```

This command will create or update the notification channels and alert policies in the `my-gcp-project`.

## Note
Ensure that the JSON files for the alert policies are correctly formatted and present in the same directory as the script. Each JSON file should contain the `displayName` field which is used to identify the alert policy.

## Alerts
- `workflow_alert_config.json` - This configuration targets alerting policy for failed Workflows
- `cdc_alert_config.json` - This configuration targets alerting policy for cdc failed tables 
- `edw_trips_file_not_found_alert_config.json` - This configuration targets alerting policy for file not found error in bankruptcy
- All other configuration files are success alerting policies for respective workflow runs.