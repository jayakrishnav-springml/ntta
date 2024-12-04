#!/bin/bash



if [ -z "$1" ]; then
    echo "Warning: project ID not passed as paramater. Please provide project ID as shown below. "
    echo "./deploy_workflow.sh  <PROJECT_ID> <SERVICE-ACCOUNT-NAME@PROJECT-ID.iam.gserviceaccount.com> <REGION> <BUCKET_NAME> <TIMEOUT_IN_SECONDS>"
    exit 1
fi

if [ -z "$2" ]; then
    echo "Warning: service account email not passed as paramater. Please provide service account email as shown below. "
    echo "./deploy_workflow.sh  <PROJECT_ID>  <SERVICE-ACCOUNT-NAME@PROJECT-ID.iam.gserviceaccount.com> <REGION> <BUCKET_NAME> <TIMEOUT_IN_SECONDS>"
    exit 1
fi

if [ -z "$3" ]; then
    echo "Warning: region to deploy workflows is not passed as paramater. Please provide region as shown below.  "
    echo "./deploy_workflow.sh  <PROJECT_ID>  <SERVICE-ACCOUNT-NAME@PROJECT-ID.iam.gserviceaccount.com> <REGION> <BUCKET_NAME> <TIMEOUT_IN_SECONDS>"
    exit 1
fi

if [ -z "$4" ]; then
    echo "Warning: Google Cloud Storage bucket is not passed as paramater. Please provide URI as shown below.  "
    echo "./deploy_workflow.sh  <PROJECT_ID>  <SERVICE-ACCOUNT-NAME@PROJECT-ID.iam.gserviceaccount.com> <REGION> <BUCKET_NAME> <TIMEOUT_IN_SECONDS>"
    exit 1
fi

if [ -z "$5" ]; then
    echo "Warning: Timeout value(seconds) is not passed as paramater. Please provide parameters as shown below.  "
    echo "./deploy_workflow.sh  <PROJECT_ID>  <SERVICE-ACCOUNT-NAME@PROJECT-ID.iam.gserviceaccount.com> <REGION> <BUCKET_NAME> <TIMEOUT_IN_SECONDS>"
    exit 1
fi

#Read Project ID as a parameter
project_id="$1"

# service_account_email which is used by workflows to execute stored procedures and other operations. Example service account is as follows.
# service_account_email="prj-ntta-bi-workflow-sa@prj-ntta-ops-bi-devt-svc-01.iam.gserviceaccount.com"
service_account_email="$2"

# Region to deploy workflows in GCP
region="$3"
# Define the parent directory

# Google Cloud Storage bucket name used by Stored Procedures to export .csv files
export_bucket_name="$4"

# Replace the timeout value based on requirement in seconds max value is 31536000. 
timeout="$5"

# parent_dir="Data_Manager_Workflows"
parent_dir="../"
parent_dir="$(realpath "$parent_dir")"


#Create temporary directory for replacing timeout parameter using sed
temp_dir=$(mktemp -d)



# Function to deploy workflow
deploy_workflow() {
    local workflow_file="$1"
    local workflow_name="$2"
    local description="$3"
    local labels="$4"
    local service_account_email="$5"

    # Run gcloud command to deploy workflow
    gcloud workflows deploy "$workflow_name" \
        --source="$workflow_file" \
        --description="$description" \
        --labels="$labels" \
        --service-account="$service_account_email" \
        --location="$region" \
        --project="$project_id"
}



replace_yaml_value() {
    local file="$1"
    local key="$2"
    local value="$3"


    # Escape special characters in the key and value
    local escaped_key=$(printf '%s\n' "$key" | sed 's/[\*\.&/\]/\\&/g')
    local escaped_value=$(printf '%s\n' "$value" | sed 's/[\/&]/\\&/g')

    # Replace the value in the YAML file
    sed -i -E "s/^(\s*(-\s*)?)${escaped_key}:.*/\1${escaped_key}: ${escaped_value}/" "$file"
    echo "$file"
}



# Function to get description from config file
get_description() {
    local config_file="$1"
    local filename="$2"

    # Read description from config file
    description=$(jq -r ".$filename.description // \"\"" "$config_file")
    echo "$description"
}

# Function to get labels from config file
get_labels() {
    local config_file="$1"
    local filename="$2"

    # Read labels from config file
    labels=$(jq -r ".$filename.labels // \"\"" "$config_file")
    echo "$labels"
}

# Function to deploy workflows in a directory
deploy_workflows_in_directory() {
    local dir="$1"

    # Loop through .yaml files in the directory
    for file in "$dir"/*.yml "$dir"/*yaml; do
        echo $file
        if [ -f "$file" ]; then
            # Extract filename without extension
            filename=$(basename -- "$file")
            filename="${filename%.*}"
            echo "Deploying workflow with ID: $filename"
            # Read description and labels from config.json
            config_file="$dir/config.json"

            # Get description and labels with error handling
            description=$(get_description "$config_file" "$filename")
            labels=$(get_labels "$config_file" "$filename")

            # Copy original YAML file to temporary directory
            cp "$file" "$temp_dir/"

            # Determine the timeout value to use
            if grep -q "GCF_TIMEOUT" "$temp_dir/$(basename "$file")"; then
                timeout_value=1800
            else
                timeout_value=$timeout
            fi
            
            # Replace timeout value and store in a temporary file
            temp_file=$(replace_yaml_value "$temp_dir/$(basename "$file")" "timeout" $timeout_value)

            # Replace bucket_name value and store in a temporary file
            temp_file=$(replace_yaml_value "$temp_file" "bucket_name" $export_bucket_name)

            # Deploy the workflow using gcloud
            deploy_workflow "$temp_file" "$filename" "$description" "$labels" "$service_account_email"

            # Remove the temporary directory
            
        fi
    done
}

# Deploy workflows in subdirectories
for dir in "$parent_dir"/*/; do
    deploy_workflows_in_directory "$dir"
done

rm -r "$temp_dir"