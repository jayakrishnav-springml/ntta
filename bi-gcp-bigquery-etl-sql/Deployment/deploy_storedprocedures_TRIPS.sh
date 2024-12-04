#!/bin/bash

echo "Scripts to create Stored Procedures for NTTA Datasets"

#replace with working project_id
# export PROJECT_ID='prj-ntta-ops-bi-devt-svc-01'
# export PROJECT_ID='ntta-gcp-poc'
PROJECT_ID="$1"

if [ -z "$1" ]; then
    echo "Warning: Project id not found. Please provide a valid project ID as parameter. "
    echo "./deploy_storedprocedures_TRIPS.sh  <PROJECT_ID>"
    exit 1
fi

TYPE="LND_TBOS_SUPPORT"

if [[ $TYPE == "LND_TBOS_SUPPORT" ]] 
then
    for SQL_FILE in $(ls -R ../LND_TBOS_SUPPORT/Routines/*.sql)
    do 
        echo $SQL_FILE

        bq query --use_legacy_sql=false --location=us-south1 --project_id=$PROJECT_ID < $SQL_FILE

    done
fi


TYPE="EDW_TRIPS_SUPPORT"

if [[ $TYPE == "EDW_TRIPS_SUPPORT" ]]
then
    for SQL_FILE in $(ls -R ../EDW_TRIPS_SUPPORT/Routines/*.sql)
    do 
        echo $SQL_FILE
        bq query --use_legacy_sql=false --location=us-south1 --project_id=$PROJECT_ID  < $SQL_FILE

    done
fi

TYPE="EDW_TRIPS_STAGE"

if [[ $TYPE == "EDW_TRIPS_STAGE" ]]
then
    for SQL_FILE in $(ls -R ../EDW_TRIPS_STAGE/Routines/*.sql)
    do 
        echo $SQL_FILE
        bq query --use_legacy_sql=false --location=us-south1 --project_id=$PROJECT_ID  < $SQL_FILE

    done
fi

TYPE="EDW_TRIPS"

if [[ $TYPE == "EDW_TRIPS" ]]
then
    for SQL_FILE in $(ls -R ../EDW_TRIPS/Routines/*.sql)
    do 
        echo $SQL_FILE
        bq query --use_legacy_sql=false --location=us-south1 --project_id=$PROJECT_ID  < $SQL_FILE

    done
fi

TYPE="FINANCE_REPORTS"

if [[ $TYPE == "FINANCE_REPORTS" ]]
then
    for SQL_FILE in $(ls -R ../FINANCE_REPORTS_EXPORT/*.sql)
    do 
        echo $SQL_FILE
        bq query --use_legacy_sql=false --location=us-south1 --project_id=$PROJECT_ID  < $SQL_FILE

    done
fi

TYPE="CHEQUE_PAYMENTS"

if [[ $TYPE == "CHEQUE_PAYMENTS" ]]
then
    for SQL_FILE in $(ls -R ../CHEQUE_PAYMENTS/Routines/*.sql)
    do
        echo $SQL_FILE
        bq query --use_legacy_sql=false --location=us-south1 --project_id=$PROJECT_ID  < $SQL_FILE

    done
fi
