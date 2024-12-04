#!/bin/bash

# Check if arguments are provided
if [ $# -ne 2 ]; then
	echo "This Scripts($0)  Requires: <project_id> and <Service-Account Email>  as Input "
    exit 1
fi

# Get arguments from command line
project_id="$1"
sa_email="$2"

echo "Deploying Cloud Function bankruptcy-import In  $1 US-South1"

gcloud functions deploy bankruptcy-import \
   --gen2 \
   --region=us-south1 \
   --project=${project_id} \
   --runtime=python310 \
   --entry-point=unzip_files \
   --build-service-account=projects/${project_id}/serviceAccounts/${sa_email} \
   --service-account=${sa_email} \
   --memory=2GB \
   --trigger-http \
   --source=.

