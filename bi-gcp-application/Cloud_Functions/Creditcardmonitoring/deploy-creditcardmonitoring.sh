#!/bin/bash

# Check if arguments are provided 1.project-id and 2.service-account email
if [ $# -ne 2 ]; then
	echo "This Scripts($0)  Requires: <project_id> and <Service-Account Email>  as Input "
    exit 1
fi

# Get arguments from command line
project_id="$1"
sa_email="$2"

echo "Deploying Cloud Function creditcardmonitoring-import In  $1 US-South1"

gcloud functions deploy creditcardmonitoring-import \
   --env-vars-file env.yaml \
   --gen2 \
   --region=us-south1 \
   --project=${project_id} \
   --runtime=python310 \
   --entry-point=CCMonitoring \
   --build-service-account=projects/${project_id}/serviceAccounts/${sa_email} \
   --service-account=${sa_email} \
   --memory=2GB \
   --trigger-http \
   --source=.
