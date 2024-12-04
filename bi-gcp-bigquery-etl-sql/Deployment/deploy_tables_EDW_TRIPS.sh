#!/bin/bash

echo "Scripts to create Tables/schema for EDW_TRIPS datasets"

# Replace with working project_id
# export PROJECT_ID='prj-ntta-ops-bi-devt-svc-01'
# export PROJECT_ID='ntta-gcp-poc'
PROJECT_ID="$1"

if [ -z "$1" ]; then
    echo "Warning: Project id not found. Please provide a valid project ID as parameter. "
    echo "./deploy_tables_EDW_TRIPS.sh  <PROJECT_ID>"
    exit 1
fi


TYPE="EDW_TRIPS"

if [[ $TYPE == "EDW_TRIPS" ]] 
then
    for SQL_FILE in $(ls -R ../EDW_TRIPS/*.sql)
    do 
        echo $SQL_FILE

        bq query --use_legacy_sql=false --location=us-south1 --project_id=$PROJECT_ID < $SQL_FILE

    done
fi