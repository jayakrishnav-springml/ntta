#!/bin/bash

timezone="America/Chicago"

# Function to log messages
log() {
    local log_type="$1"
    local log_message="$2"
    current_datetime=$(TZ="$timezone" date +"%Y-%m-%dT%H:%M:%S")
    message="$current_datetime - $log_message"
    echo "$log_type - $message"
    gcloud logging write "data_loading" "${log_message}" --severity=${log_type} --project=${project_id}
}


# Function to check command success and log error if failed
check_command_success() {
  if [ $? -ne 0 ]; then
    log "ERROR" "$1"
    exit 1
  fi
}

# Validate input parameters
if [ -z "$1" ] || [ -z "$2" ] || [ -z "$3" ] || [ -z "$4" ]; then
  log "ERROR" "Usage: $0 <config_file> <run_flag> <service_account_email> <startup_script_bucket_name>"
  exit 1
fi

# Command-line parameters
config_file="$1"
run_flag="$2"
service_account_email="$3"
startup_script_bucket_name="$4"

# Check if the JSON file exists.
if [ ! -f "$config_file" ]; then
    log "Error" "JSON file '$config_file' not found."
    exit 1
fi

project_id=$(jq -r '.project_id' "$config_file")

# Log starting the deployment
log "INFO" "Starting deployment..."

# Create a copy of startup_script.sh to modify
cp startup_script.sh startup_script_temp.sh
check_command_success "Failed to copy startup_script.sh to startup_script_temp.sh"

# Replace placeholders in the copied script with actual values
sed -i "s|<config.json>|${config_file}|g" startup_script_temp.sh
check_command_success "Failed to replace <config.json> placeholder"
sed -i "s|<service_account_email>|${service_account_email}|g" startup_script_temp.sh
check_command_success "Failed to replace <service_account_email> placeholder"
sed -i "s|<script_bucket_name>|${startup_script_bucket_name}|g" startup_script_temp.sh
check_command_success "Failed to replace <script_bucket_name> placeholder"
sed -i "s|<run_flag(Y/N)>|${run_flag}|g" startup_script_temp.sh
check_command_success "Failed to replace <run_flag(Y/N)> placeholder"

gcs_path="gs://${startup_script_bucket_name}/Data_Loading_Scripts/"

# Clean up GCS path if there are files
log "INFO" "Checking if GCS path contains files..."
if gsutil ls "${gcs_path}" > /dev/null 2>&1; then
  log "INFO" "Cleaning up GCS path..."
  gsutil -m rm -r "${gcs_path}*" 2>/dev/null
  check_command_success "Failed to clean up GCS path"
else
  log "INFO" "GCS path is already clean, no files to remove."
fi

# Copy files to GCS
log "INFO" "Copying files to GCS..."
find . -type f \( -name "*.sh" -o -name "*.py" -o -name "*.json" \) ! -name "startup_script.sh" ! -name "startup_script_temp.sh" -print0 | while IFS= read -r -d '' file; do
  gsutil -m cp "$file" "${gcs_path}${file#./}"
  check_command_success "Failed to copy $file to GCS"
done

# Copy the modified startup_script_temp.sh as the new startup_script.sh to GCS
gsutil -m cp startup_script_temp.sh "gs://${startup_script_bucket_name}/Data_Loading_Scripts/startup_script.sh"
check_command_success "Failed to copy startup_script_temp.sh to GCS"

# Clean up temporary file
sudo rm startup_script_temp.sh
check_command_success "Failed to remove temporary script file"

# Log completion of deployment
log "INFO" "Deployment completed successfully."
