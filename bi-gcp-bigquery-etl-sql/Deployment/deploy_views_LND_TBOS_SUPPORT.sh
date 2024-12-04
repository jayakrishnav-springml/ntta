#!/bin/bash

echo "Scripts to create views for LND_TBOS_SUPPORT datasets"

# Replace with working project_id
# export PROJECT_ID='prj-ntta-ops-bi-devt-svc-01'
# export PROJECT_ID='ntta-gcp-poc'
PROJECT_ID="$1"

if [ -z "$1" ]; then
    echo "Warning: Project id not found. Please provide a valid project ID as parameter. "
    echo "./deploy_views_LND_TBOS_SUPPORT.sh  <PROJECT_ID>"
    exit 1
fi

bq query --use_legacy_sql=false --location=us-south1 --project_id=$PROJECT_ID < ../LND_TBOS_SUPPORT/Views/Utility_vw_FullLoadTracker.sql
bq query --use_legacy_sql=false --location=us-south1 --project_id=$PROJECT_ID < ../LND_TBOS_SUPPORT/Views/Utility_vw_CDCCompareSummary.sql
bq query --use_legacy_sql=false --location=us-south1 --project_id=$PROJECT_ID < ../LND_TBOS_SUPPORT/Views/Utility_vw_CDCCompareDetail.sql
bq query --use_legacy_sql=false --location=us-south1 --project_id=$PROJECT_ID < ../LND_TBOS_SUPPORT/Views/Utility_vw_Archive_Delete_LandingDataProfile.sql

