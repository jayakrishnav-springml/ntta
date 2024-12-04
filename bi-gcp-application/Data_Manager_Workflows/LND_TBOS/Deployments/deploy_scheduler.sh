#!/bin/bash

# Function to deploy scheduler
deploy_scheduler() {
    local job_name="$1"
	local schedule="$2"
    local message_body="$3"
	local oidc_service_account_email="$4"
    local location="$5"
    local workflow_id="$6"
    local time_zone="$7"


    list_of_scheduler_ids=$(gcloud scheduler jobs list --location=us-central1 --format="value(ID)")
    workflow_name=$(gcloud workflows describe "$workflow_id" --location=us-south1 --format="value(name)")

    IFS=$'\n' read -rd '' -a list_of_scheduler_ids_array <<< "$list_of_scheduler_ids"

    exists=false

    for scheduler_id in "${list_of_scheduler_ids_array[@]}"; do
        if [[ "$scheduler_id" == "$job_name" ]]; then
            exists=true
        fi
    done
    if [ "$exists" = true ]; then
        echo "The schedule with the name $job_name already exists. updating the schedule..."
        # Run gcloud command to deploy scheduler
        gcloud scheduler  jobs update http "$job_name" \
        --location="$location" \
        --oauth-service-account-email="$oidc_service_account_email" \
        --schedule="$schedule" \
        --uri="https://workflowexecutions.googleapis.com/v1/$workflow_name/executions" \
        --message-body="$message_body" \
        --time-zone="$time_zone"
       
    else
        echo "Creating schedule with the name $job_name ..."

        #Run gcloud command to deploy scheduler

        gcloud scheduler jobs create http "$job_name" \
        --location="$location" \
        --oauth-service-account-email="$oidc_service_account_email" \
        --schedule="$schedule" \
        --uri="https://workflowexecutions.googleapis.com/v1/$workflow_name/executions" \
        --message-body="$message_body"\
        --time-zone="$time_zone"
      
    fi

    
}

if [ -z "$1" ]; then
    echo "Warning: service account email not passed as paramater. Please provide parameter as shown below. "
    echo "./deploy_scheduler.sh <SERVICE-ACCOUNT-NAME@PROJECT-ID.iam.gserviceaccount.com>"
    exit 1
fi

# service_account_email="prj-ntta-bi-workflow-sa@prj-ntta-ops-bi-devt-svc-01.iam.gserviceaccount.com"\
service_account_email="$1"

# Loop through .yml files in the subfolder
for file in  $(ls -R ../Parent_Workflows/*.yml); do
    # Extract filename without extension
    if [ -f "$file" ]; then
        workflow_id=$(basename -- "$file" .yml)

        # Read description and labels from scheduling_config.json
        scheduling_config="scheduling_config.json"
        # check if workflow_id is present in scheduling_config.json file 
        if jq -e ".\"$workflow_id\"" "$scheduling_config" >/dev/null; then
            
        
            job_name=$(jq -r ".$workflow_id.job_name" "$scheduling_config")
            schedule=$(jq -r ".$workflow_id.schedule" "$scheduling_config")
            message_body=$(jq -r ".$workflow_id.message_body" "$scheduling_config")
            location=$(jq -r ".$workflow_id.location" "$scheduling_config")
            time_zone=$(jq -r ".$workflow_id.time_zone" "$scheduling_config")

            # Deploy the scheduler using gcloud
            #gcloud scheduler deploy "$filename" --source="$file" --description="$description" --labels="$labels" --service-account=YOUR_SERVICE_ACCOUNT_EMAIL --project=YOUR_PROJECT_ID
            deploy_scheduler "$job_name" "$schedule"  "$message_body" "$service_account_email" "$location" "$workflow_id" "$time_zone"
        else
            echo "Schedule for workflows ID \"$workflow_id\" does not exist in the schedule configuration file."
        fi
    fi
done




