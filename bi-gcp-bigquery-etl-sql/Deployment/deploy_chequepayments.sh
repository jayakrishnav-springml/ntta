#!/bin/bash

echo "Script to deploy Cheque Payments Stored Procedure"

#replace with working project_id
# export PROJECT_ID='prj-ntta-ops-bi-devt-svc-01'
# export PROJECT_ID='ntta-gcp-poc'
PROJECT_ID="$1"

if [ -z "$1" ]; then
    echo "Warning: Project id not found. Please provide a valid project ID as parameter. "
    echo "./deploy_chequepayments.sh  <PROJECT_ID>"
    exit 1
fi

TYPE="CHEQUE_PAYMENTS"

if [[ $TYPE == "CHEQUE_PAYMENTS" ]] 
then
    for SQL_FILE in $(ls -R ../CHEQUE_PAYMENTS/Routines/*.sql)
    do 
        echo $SQL_FILE

        bq query --use_legacy_sql=false --location=us-south1 --project_id=$PROJECT_ID < $SQL_FILE

    done
fi