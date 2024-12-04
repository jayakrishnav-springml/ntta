#!/bin/bash

# Get the current datetime in the specified timezone
timezone="America/Chicago"
current_date=$(TZ=$timezone date +"%Y-%m-%d")

# Function to log messages
log() {
    local log_type="$1"
    local log_message="$2"
    current_datetime=$(TZ="$timezone" date +"%Y-%m-%dT%H:%M:%S")
    message="$current_datetime - $log_message"
    echo "$log_type - $message"
    gcloud logging write "data_loading" "${log_message}" --severity=${log_type} --project=${project_id}
}


# Check if the configuration file path and run_flag paramater is provided as a command-line argument

if [ -z "$1" ]; then
    log "ERROR" "configuration file path has not been provided as a command-line argument. Please provide configuration file path as shown below. "
    log "INFO" "./load.sh config.json <run_flag(Y/N)> <SERVICE-ACCOUNT-NAME@PROJECT-ID.iam.gserviceaccount.com>"   
    exit 1
fi

if [ -z "$2" ]; then
    log "ERROR" "run_flag paramater has not been provided as a command-line argument. Please provide run_flag paramater as shown below. "
    log "INFO" "./load.sh config.json <run_flag(Y/N)> <SERVICE-ACCOUNT-NAME@PROJECT-ID.iam.gserviceaccount.com>"
    exit 1
fi

if [ -z "$3" ]; then
    log "ERROR" "service account email not passed as paramater. Please provide service account email as shown below. "
    log "INFO" "./load.sh config.json <run_flag(Y/N)> <SERVICE-ACCOUNT-NAME@PROJECT-ID.iam.gserviceaccount.com>"
    exit 1
fi

# Extracting the file path argument.
json_file="$1"
run_flag="$2"

# Check if the JSON file exists.
if [ ! -f "$json_file" ]; then
    log "Error" "JSON file '$json_file' not found."
    exit 1
fi


# Check if the loading_stats file exists.
if [ ! -f "loading_stats.py" ]; then
    log "Error" "loading_stats file 'loading_stats.py' not found."
    exit 1
fi


# service_account_email which is used by loading_stats script to filter load job. Example service account is as follows.
service_account_email="$3"

# Read values from the JSON file.
project_id=$(jq -r '.project_id' "$json_file")
bucket_name=$(jq -r '.gcs_bucket_name' "$json_file")
archive_bucket_name=$(jq -r '.gcs_archive_bucket_name' "$json_file")
full_load_dataset_names=($(jq -r '.full_load_dataset_names[]' "$json_file"))
full_load_dataset_flag=$(jq -r '.full_load_dataset_flag' "$json_file")
gcs_bucket_path="gs://${bucket_name}"
partial_load_list=$(jq -r '.partial_load_list' "$json_file")
partial_load_flag=$(jq -r '.partial_load_flag' "$json_file")

# utc_datetime for getting Load statistics.
utc_datetime=$(date -u +"%Y-%m-%dT%H:%M:%S")

# Function to check if a directory exists in GCS.
dir_exists_in_gcs() {
    local path=$1
    gsutil ls "$path" &> /dev/null

}

if [ "$run_flag" == "N" ]; then
   log "INFO" "Since run_flag is set to 'N', all commands will be echoed but not executed."
fi
#  Code to loads all tables within the datasets listed in full_load_dataset_names.

# Check if full_load_dataset_flag is set to "Y".
if [ "$full_load_dataset_flag" == "Y" ]; then
     log "INFO" "BQ execution initiated for all tables within the specified dataset names listed in '$full_load_dataset_names'."
    # Check if full_load_dataset_names is empty.
    if [ -z "$full_load_dataset_names" ]; then
        log "INFO" "The '${full_load_dataset_names}' array is empty."
    else
        # Loop through each dataset name.
        for full_load_dataset_name in "${full_load_dataset_names[@]}"; do
            full_load_gcs_dir_path="${gcs_bucket_path}/${full_load_dataset_name}"
            # Check if the directory exists in GCS.
            if ! dir_exists_in_gcs "${full_load_gcs_dir_path}"; then
                log "ERROR" "Directory ${full_load_gcs_dir_path} does not exist in GCS."
                continue
            fi
            # Loop through each table path and, if the `run_flag` is set to "Y," execute the `bq load` command. Depending on the load job status, move the files to either the archive or failed directory.
            for full_load_gcs_file_path in $(gsutil ls "$full_load_gcs_dir_path" | grep -v "$full_load_gcs_dir_path/$"); do
                full_load_table_name=$(echo "$full_load_gcs_file_path" | awk -F'/' '{print $(NF-1)}')
                full_load_dataset_name=$(echo "$full_load_gcs_file_path" | awk -F'/' '{print $(NF-2)}')              
               full_load_bq_table_id="${project_id}:${full_load_dataset_name}.${full_load_table_name}"
                log "INFO" "bq load --project_id=${project_id} --location=us-south1  --sync=true --source_format=CSV --preserve_ascii_control_characters=true --field_delimiter=|  --replace=true  --allow_quoted_newlines=true --allow_jagged_rows=true ${full_load_bq_table_id} ${full_load_gcs_file_path}*.csv"
                if [ "$run_flag" == "Y" ]; then
                    # Execute the BQ load command
                    log "INFO" "Initiating load job for table ${full_load_dataset_name}.${full_load_table_name}"
                    full_load_bq_output=$(bq load --project_id="${project_id}" --location=us-south1  --sync=true --source_format=CSV --preserve_ascii_control_characters=true --field_delimiter="|"  --replace=true  --allow_quoted_newlines=true --allow_jagged_rows=true "${full_load_bq_table_id}" "${full_load_gcs_file_path}*.csv" 2>&1)
                    full_load_bq_exit_code=$?

                    if [ ${full_load_bq_exit_code} -eq 0 ]; then
                        # Move files to the archive folder
                        gsutil -m mv ${gcs_bucket_path}/${full_load_dataset_name}/${full_load_table_name} gs://${archive_bucket_name}/ARCHIVE/${current_date}/${full_load_dataset_name}/
                        if gsutil ls -d ${gcs_bucket_path}/${full_load_dataset_name}/${full_load_table_name} > /dev/null 2>&1; then
                            gsutil -m rm -r ${gcs_bucket_path}/${full_load_dataset_name}/${full_load_table_name}
                        fi   
                        log "INFO" "Files from ${gcs_bucket_path}/${full_load_dataset_name}/${full_load_table_name} archived to gs://${archive_bucket_name}/ARCHIVE/${current_date}/${full_load_dataset_name}/"                
                    else
                        if [[ "$full_load_bq_output" != *"No schema specified"* ]]; then
                            # Move files to the failed folder
                            gsutil -m mv ${gcs_bucket_path}/${full_load_dataset_name}/${full_load_table_name} gs://${archive_bucket_name}/FAILED/${current_date}/${full_load_dataset_name}/
                            if gsutil ls -d ${gcs_bucket_path}/${full_load_dataset_name}/${full_load_table_name} > /dev/null 2>&1; then
                                gsutil -m rm -r ${gcs_bucket_path}/${full_load_dataset_name}/${full_load_table_name}
                            fi
                            log "ERROR" "Loading failed. Files from ${full_load_gcs_file_path} have been moved to gs://${archive_bucket_name}/FAILED/${current_date}/${full_load_dataset_name}/"
                        else
                            log "ERROR" "Table ${full_load_dataset_name}.${full_load_table_name} is not created on BQ."
                        fi
                    fi
                fi
            done
        done
    fi
    log "INFO" "Load jobs for all tables within the specified datasets have been initiated if files are present under the datasets listed in full_load_dataset_names."
fi

# Code to load only the tables specified in the partial_load_list.

partial_load_dataset_list=$(echo "$partial_load_list" | jq -r 'keys[]')

# Check if full_load_dataset_flag is set to "Y".
if [ "$partial_load_flag" == "Y" ]; then
    log "INFO" "The execution of BigQuery has been initiated for the specified tables under the dataset names mentioned in the '$partial_load_dataset_list'."
    # Check if the dataset list is empty.
    if [ -z "$partial_load_dataset_list" ]; then
        log "INFO" "The '$partial_load_dataset_list' array is empty."
    else
        # Loop through each dataset.
        for partial_load_dataset_name in $partial_load_dataset_list; do
            partial_load_gcs_dir_path="${gcs_bucket_path}/${partial_load_dataset_name}/"
            if ! dir_exists_in_gcs "$partial_load_gcs_dir_path"; then
                log "INFO" "Directory $partial_load_gcs_dir_path does not exist in GCS."
                continue
            fi
            # Get the tables names for the current dataset.
            partial_load_tables_list=$(echo "$partial_load_list" | jq -r ".[\"$partial_load_dataset_name\"][]")
            # Loop through each table name and, if the `run_flag` is set to "Y", execute the `bq load` command. Depending on the load job status, move the files to either the archive or failed directory.
            for partial_load_table_name in $partial_load_tables_list; do
                partial_load_gcs_table_path="${gcs_bucket_path}/${partial_load_dataset_name}/${partial_load_table_name}"
                if ! dir_exists_in_gcs "${partial_load_gcs_table_path}"; then
                    log "ERROR" "Files for the table ${partial_load_gcs_table_path} does not exist in GCS."
                    continue
                fi
                partial_load_bq_table_id="${project_id}":"${partial_load_dataset_name}"."${partial_load_table_name}"
                log "INFO" "bq load --project_id=${project_id} --location=us-south1  --sync=true --source_format=CSV --preserve_ascii_control_characters=true --field_delimiter=|  --replace=true  --allow_quoted_newlines=true --allow_jagged_rows=true ${partial_load_bq_table_id} ${partial_load_gcs_table_path}/*.csv"
                if [ "$run_flag" == "Y" ]; then
                    # Execute the BQ load command
                    log "INFO" "Initiating load job for table ${partial_load_dataset_name}.${partial_load_table_name}"
                    partial_bq_output=$(bq load --project_id="${project_id}" --location=us-south1  --sync=true --source_format=CSV --preserve_ascii_control_characters=true  --replace=true  --allow_quoted_newlines=true --field_delimiter="|" --allow_jagged_rows=true "$partial_load_bq_table_id" "${partial_load_gcs_table_path}/*.csv" 2>&1)
                    partial_bq_exit_code=$?

                    if [ ${partial_bq_exit_code} -eq 0 ]; then
                        # Move files to the archive folder
                        gsutil -m mv ${partial_load_gcs_table_path} gs://${archive_bucket_name}/ARCHIVE/${current_date}/${partial_load_dataset_name}/
                        if gsutil ls -d ${gcs_bucket_path}/${partial_load_dataset_name}/${partial_load_table_name} > /dev/null 2>&1; then
                            gsutil -m rm -r ${gcs_bucket_path}/${partial_load_dataset_name}/${partial_load_table_name}
                        fi
                        log "INFO" "Files from  ${gcs_bucket_path}/${partial_load_dataset_name}/${partial_load_table_name} archived to gs://${archive_bucket_name}/ARCHIVE/${current_date}/${partial_load_dataset_name}/"
                    else
                        if [[ "$partial_bq_output" != *"No schema specified on job"* ]]; then
                            # Move files to the failed folder
                            gsutil -m mv ${partial_load_gcs_table_path} gs://${archive_bucket_name}/FAILED/${current_date}/${partial_load_dataset_name}/
                            if gsutil ls -d ${gcs_bucket_path}/${partial_load_dataset_name}/${partial_load_table_name} > /dev/null 2>&1; then
                                gsutil -m rm -r ${gcs_bucket_path}/${partial_load_dataset_name}/${partial_load_table_name}
                            fi  
                            log "ERROR" "Loading failed. Files from ${gcs_bucket_path}/${partial_load_dataset_name}/${partial_load_table_name} moved to gs://${archive_bucket_name}/FAILED/${current_date}/${partial_load_dataset_name}/"               
                        else
                            log "ERROR" "Table ${partial_load_dataset_name}.${partial_load_table_name} is not created on BQ."
                        fi

                    fi
                fi

            done
        done
    fi
    log "INFO" "Load jobs for the specified tables are initiated if files for a particular table in GCS, under the dataset names mentioned in the partial_load_list, are available."
fi


# Execute python script if run_flag is set to "Y",
if [ "$run_flag" == "Y" ]; then
    log "INFO" "Executing loading_stats.py"
    python loading_stats.py "$json_file" "$utc_datetime" "$service_account_email"
    if [ $? -ne 0 ]; then
        log "ERROR" "Failed to execute loading_stats.py with ${json_file}"
        exit 1
    else
        log "INFO" "loading_stats.py executed successfully with ${json_file}"
    fi
fi