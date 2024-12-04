#!/bin/bash

echo "Scripts to create views for all EDW_SHARED_DATA Creditcardmonitoring"

# Replace with working project_id
# export PROJECT_ID='prj-ntta-ops-bi-devt-svc-01'
PROJECT_ID="$1"

if [ -z "$1" ]; then
    echo "Warning: Project id not found. Please provide a valid project ID as parameter. "
    echo "./deploy_views_EDW_SHARED_DATA.sh  <PROJECT_ID>"
    exit 1
fi

bq query --use_legacy_sql=false --location=us-south1 --project_id=$PROJECT_ID < ../EDW_SHARED_DATA/Views/CCM_Exception_Detail_ACT0002_VW.sql
bq query --use_legacy_sql=false --location=us-south1 --project_id=$PROJECT_ID < ../EDW_SHARED_DATA/Views/CCM_Deposit_Detail_ACT0010_VW.sql