#!/bin/bash

echo "Script to deploy Chargeback Stored Procedures and tables"

#replace with working project_id
# export PROJECT_ID='prj-ntta-ops-bi-devt-svc-01'
# export PROJECT_ID='ntta-gcp-poc'
PROJECT_ID="$1"

if [ -z "$1" ]; then
    echo "Warning: Project id not found. Please provide a valid project ID as parameter. "
    echo "./deploy_chargeback.sh  <PROJECT_ID>"
    exit 1
fi

TYPE="CHARGEBACK"

if [[ $TYPE == "CHARGEBACK" ]] 
then
    for SQL_FILE in $(ls -R ../CHARGEBACK/Routines/*.sql)
    do 
        echo $SQL_FILE

        bq query --use_legacy_sql=false --location=us-south1 --project_id=$PROJECT_ID < $SQL_FILE

    done
fi


##  Use this only to re-deploy the tables when necessary

# bq query --use_legacy_sql=false --location=us-south1 --project_id=$PROJECT_ID < ../LND_TBOS/dbo_CB_*.sql
# bq query --use_legacy_sql=false --location=us-south1 --project_id=$PROJECT_ID < ../LND_TBOS/dbo_ChargeBack_*.sql
# bq query --use_legacy_sql=false --location=us-south1 --project_id=$PROJECT_ID < ../LND_TBOS_STAGE_FULL/Stage_ChargeBack*.sql



