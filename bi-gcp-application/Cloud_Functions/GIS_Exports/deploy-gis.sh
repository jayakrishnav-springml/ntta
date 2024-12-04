#!/bin/bash

# Check if arguments are provided
if [ $# -ne 2 ]; then
	echo "This Scripts($0)  Requires: <project_id> and <Service-Account Email>  as Input "
    exit 1
fi

# Get arguments from command line
project_id="$1"
sa_email="$2"

echo "Deploying Cloud Function gis-exports in  $1 us-south1"

gcloud functions deploy gis-exports \
   --gen2 \
   --region=us-south1 \
   --project=${project_id} \
   --runtime=python310 \
   --entry-point=gis_exports \
   --build-service-account=projects/${project_id}/serviceAccounts/${sa_email} \
   --service-account=${sa_email} \
   --memory=4GB \
   --trigger-http \
   --no-allow-unauthenticated \
   --timeout=3600 \
   --source=.

