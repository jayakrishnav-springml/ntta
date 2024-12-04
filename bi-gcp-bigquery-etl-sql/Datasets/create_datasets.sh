#!/bin/bash

# Replace with working project_id
# export PROJECT_ID='prj-ntta-ops-bi-devt-svc-01'
# export PROJECT_ID='ntta-gcp-poc'
PROJECT_ID="$1"

if [ -z "$1" ]; then
    echo "Warning: Project id not found. Please provide a valid project ID as parameter. "
    echo "./create_datasets.sh  <PROJECT_ID>"
    exit 1
fi

bq query --use_legacy_sql=false --location=us-south1 --project_id=$PROJECT_ID < LND_TBOS_datasets.sql
bq query --use_legacy_sql=false --location=us-south1 --project_id=$PROJECT_ID < EDW_TRIPS_datasets.sql
bq query --use_legacy_sql=false --location=us-south1 --project_id=$PROJECT_ID < APS_datasets.sql
bq query --use_legacy_sql=false --location=us-south1 --project_id=$PROJECT_ID < FINANCE_REPORTS_EXPORT_dataset.sql
bq query --use_legacy_sql=false --location=us-south1 --project_id=$PROJECT_ID < EDW_RITE_datasets.sql
bq query --use_legacy_sql=false --location=us-south1 --project_id=$PROJECT_ID < EDW_NAGIOS_datasets.sql
bq query --use_legacy_sql=false --location=us-south1 --project_id=$PROJECT_ID < LND_NAGIOS_datasets.sql
bq query --use_legacy_sql=false --location=us-south1 --project_id=$PROJECT_ID < APS_NAGIOS_datasets.sql
bq query --use_legacy_sql=false --location=us-south1 --project_id=$PROJECT_ID < FILES_EXPORT_dataset.sql
bq query --use_legacy_sql=false --location=us-south1 --project_id=$PROJECT_ID < SANDBOX_dataset.sql
bq query --use_legacy_sql=false --location=us-south1 --project_id=$PROJECT_ID < LND_TBOS_Archival_datasets.sql