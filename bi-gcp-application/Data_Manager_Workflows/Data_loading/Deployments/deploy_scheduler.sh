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
    echo "Warning: service account email not passed as parameter. Please provide parameter as shown below. "
    echo "./deploy_scheduler.sh <SERVICE-ACCOUNT-NAME@PROJECT-ID.iam.gserviceaccount.com> <VM_INSTANCE_NAME> <VM_INSTANCE_ZONE>"
    exit 1
fi

if [ -z "$2" ]; then
    echo "Warning: instance id not passed as parameter. Please provide parameter as shown below. "
    echo "./deploy_scheduler.sh <SERVICE-ACCOUNT-NAME@PROJECT-ID.iam.gserviceaccount.com> <VM_INSTANCE_NAME> <VM_INSTANCE_ZONE>"
    exit 1
fi

if [ -z "$3" ]; then
    echo "Warning: zone not passed as parameter. Please provide parameter as shown below. "
    echo "./deploy_scheduler.sh <SERVICE-ACCOUNT-NAME@PROJECT-ID.iam.gserviceaccount.com> <VM_INSTANCE_NAME> <VM_INSTANCE_ZONE>"
    exit 1
fi

# service_account_email="prj-ntta-bi-workflow-sa@prj-ntta-ops-bi-devt-svc-01.iam.gserviceaccount.com"\
service_account_email="$1"
instance_id="$2"
zone="$3"


# Loop through .yml files in the subfolder
for file in $(ls -R ../Parent_Workflows/*.yml); do
    # Extract filename without extension
    if [ -f "$file" ]; then
        workflow_id=$(basename -- "$file" .yml)

        # Read description and labels from scheduling_config.json
        scheduling_config="scheduling_config.json"
        # Check if workflow_id is present in scheduling_config.json file 
        if jq -e ".\"$workflow_id\"" "$scheduling_config" >/dev/null; then
            # Check if the workflow_id is an array
            if jq -e ".\"$workflow_id\" | type == \"array\"" "$scheduling_config" >/dev/null; then
                # It's an array, so loop through each schedule
                schedules=$(jq -c ".\"$workflow_id\"[]" "$scheduling_config")
                echo "$schedules" | while IFS= read -r schedule; do
                    job_name=$(echo "$schedule" | jq -r ".job_name")
                    schedule_time=$(echo "$schedule" | jq -r ".schedule")
                    message_body=$(echo "$schedule" | jq -r ".message_body")
                    # Use sed to replace the placeholders with the new values
                    message_body=$(echo $message_body | sed "s/<instance_id>/$instance_id/g")
                    message_body=$(echo $message_body | sed "s/<zone>/$zone/g")
                    location=$(echo "$schedule" | jq -r ".location")
                    time_zone=$(echo "$schedule" | jq -r ".time_zone")
                    # Deploy the scheduler using gcloud
                    deploy_scheduler "$job_name" "$schedule_time"  "$message_body" "$service_account_email" "$location" "$workflow_id" "$time_zone"
                done
            else
                # It's a single object, handle it directly
                schedule=$(jq -c ".\"$workflow_id\"" "$scheduling_config")
                job_name=$(echo "$schedule" | jq -r ".job_name")
                schedule_time=$(echo "$schedule" | jq -r ".schedule")
                message_body=$(echo "$schedule" | jq -r ".message_body")
                location=$(echo "$schedule" | jq -r ".location")
                time_zone=$(echo "$schedule" | jq -r ".time_zone")
                # Deploy the scheduler using gcloud
                deploy_scheduler "$job_name" "$schedule_time"  "$message_body" "$service_account_email" "$location" "$workflow_id" "$time_zone"
            fi
        else
            echo "Schedule for workflow ID \"$workflow_id\" does not exist in the schedule configuration file."
        fi
    fi
done
