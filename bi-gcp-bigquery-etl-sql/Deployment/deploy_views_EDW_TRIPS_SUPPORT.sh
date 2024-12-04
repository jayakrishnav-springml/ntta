#!/bin/bash

echo "Scripts to create views for EDW_TRIPS_SUPPORT datasets"

# Replace with working project_id
# export PROJECT_ID='prj-ntta-ops-bi-devt-svc-01'
# export PROJECT_ID='ntta-gcp-poc'
PROJECT_ID="$1"

if [ -z "$1" ]; then
    echo "Warning: Project id not found. Please provide a valid project ID as parameter. "
    echo "./deploy_views_EDW_TRIPS_SUPPORT.sh  <PROJECT_ID>"
    exit 1
fi

#uncomment and run once LND_TER and EDW_TER databases along with tables are created
bq query --use_legacy_sql=false --location=us-south1 --project_id=$PROJECT_ID < ../EDW_TRIPS_SUPPORT/Views/Ref_vw_Vrb.sql