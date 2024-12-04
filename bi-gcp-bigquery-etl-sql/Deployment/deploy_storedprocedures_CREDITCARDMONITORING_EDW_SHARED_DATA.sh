#!/bin/bash

echo "Scripts to create Stored Procedures for EDW_SHARED_DATA dataset"

#replace with working project_id
# export PROJECT_ID='prj-ntta-ops-bi-devt-svc-01'
PROJECT_ID="$1"

if [ -z "$1" ]; then
    echo "Warning: Project id not found. Please provide a valid project ID as parameter. "
    echo "./deploy_storedprocedures_Creditcardmonitoring.sh  <PROJECT_ID>"
    exit 1
fi

TYPE="EDW_SHARED_DATA"

if [[ $TYPE == "EDW_SHARED_DATA" ]] 
then
    for SQL_FILE in $(ls -R ../EDW_SHARED_DATA/Routines/*.sql)
    do 
        echo $SQL_FILE

        bq query --use_legacy_sql=false --location=us-south1 --project_id=$PROJECT_ID < $SQL_FILE

    done
fi