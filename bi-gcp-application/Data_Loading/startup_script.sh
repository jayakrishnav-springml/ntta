#!/bin/bash

timezone="America/Chicago"

sudo rm -rf /data_loading
sudo mkdir -p /data_loading
cd /data_loading

# Function to log messages
log() {
    local log_type="$1"
    local log_message="$2"
    current_datetime=$(TZ="$timezone" date +"%Y-%m-%dT%H:%M:%S")
    message="$current_datetime - $log_message"
    echo "$log_type - $message"
    gcloud logging write "data_loading" "${log_message}" --severity=${log_type} --project=${project_id}
}

check_command_success() {
  if [ $? -ne 0 ]; then
    log "ERROR" "$1"
  fi
}

# Parameters
config_file="<config.json>"
run_flag="<run_flag(Y/N)>"
service_account_email="<service_account_email>"
startup_script_bucket_name="<script_bucket_name>"
loading_script="load.sh"


startup_script_gcs_path="gs://${startup_script_bucket_name}/Data_Loading_Scripts/*"



# Copy files from the GCS bucket to the local machine

sudo gsutil -m cp -r ${startup_script_gcs_path} .
check_command_success "Failed to copy files from GCS"

project_id=$(jq -r '.project_id' "$config_file")

# Ensure the loading script has executable permissions
sudo chmod +x "$loading_script"
check_command_success "Failed to set executable permissions on $loading_script"

# Execute the loading script
log "INFO" "Executing loading script..."
./$loading_script ${config_file} ${run_flag} ${service_account_email}
check_command_success "Failed to execute loading script"

# Uncomment below commands to shutdown vm instance after data_loading process is done.

log "INFO" "VM startup script completed successfully. Shutting down the VM."
sudo shutdown -h now    
check_command_success "Failed to shut down VM"
