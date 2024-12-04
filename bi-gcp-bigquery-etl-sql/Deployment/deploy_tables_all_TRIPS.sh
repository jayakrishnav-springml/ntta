#!/bin/bash

echo "Scripts to create Tables/schema for LND_TBOS dataset"

# Replace with working project_id
# export PROJECT_ID='prj-ntta-ops-bi-devt-svc-01'
# export PROJECT_ID='ntta-gcp-poc'/
PROJECT_ID="$1"

if [ -z "$1" ]; then
    echo "Warning: Project id not found. Please provide a valid project ID as parameter. "
    echo "./deploy_tables_all_datasets.sh  <PROJECT_ID>"
    exit 1
fi

TYPE="LND_TBOS"

if [[ $TYPE == "LND_TBOS" ]] 
then
    for SQL_FILE in $(ls -R ../LND_TBOS/*.sql)
    do 
        echo $SQL_FILE

        bq query --use_legacy_sql=false --location=us-south1 --project_id=$PROJECT_ID < $SQL_FILE

    done
fi

TYPE="LND_TBOS_STAGE_FULL"

if [[ $TYPE == "LND_TBOS_STAGE_FULL" ]] 
then
    for SQL_FILE in $(ls -R ../LND_TBOS_STAGE_FULL/*.sql)
    do 
        echo $SQL_FILE

        bq query --use_legacy_sql=false --location=us-south1 --project_id=$PROJECT_ID < $SQL_FILE

    done
fi

TYPE="LND_TBOS_STAGE_CDC"

if [[ $TYPE == "LND_TBOS_STAGE_CDC" ]] 
then
    for SQL_FILE in $(ls -R ../LND_TBOS_STAGE_CDC/*.sql)
    do 
        echo $SQL_FILE

        bq query --use_legacy_sql=false --location=us-south1 --project_id=$PROJECT_ID < $SQL_FILE

    done
fi

TYPE="LND_TBOS_SUPPORT"

if [[ $TYPE == "LND_TBOS_SUPPORT" ]] 
then
    for SQL_FILE in $(ls -R ../LND_TBOS_SUPPORT/*.sql)
    do 
        echo $SQL_FILE

        bq query --use_legacy_sql=false --location=us-south1 --project_id=$PROJECT_ID < $SQL_FILE

    done
fi

TYPE="LND_TBOS_ARCHIVE"

if [[ $TYPE == "LND_TBOS_ARCHIVE" ]] 
then
    for SQL_FILE in $(ls -R ../LND_TBOS_ARCHIVE/*.sql)
    do 
        echo $SQL_FILE

        bq query --use_legacy_sql=false --location=us-south1 --project_id=$PROJECT_ID < $SQL_FILE

    done
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

TYPE="EDW_TRIPS_SUPPORT"

if [[ $TYPE == "EDW_TRIPS_SUPPORT" ]] 
then
    for SQL_FILE in $(ls -R ../EDW_TRIPS_SUPPORT/*.sql)
    do 
        echo $SQL_FILE

        bq query --use_legacy_sql=false --location=us-south1 --project_id=$PROJECT_ID < $SQL_FILE

    done
fi

TYPE="EDW_TRIPS_STAGE"

if [[ $TYPE == "EDW_TRIPS_STAGE" ]] 
then
    for SQL_FILE in $(ls -R ../EDW_TRIPS_STAGE/*.sql)
    do 
        echo $SQL_FILE

        bq query --use_legacy_sql=false --location=us-south1 --project_id=$PROJECT_ID < $SQL_FILE

    done
fi

TYPE="EDW_TRIPS_APS"

if [[ $TYPE == "EDW_TRIPS_APS" ]] 
then
    for SQL_FILE in $(ls -R ../EDW_TRIPS_APS/*.sql)
    do 
        echo $SQL_FILE

        bq query --use_legacy_sql=false --location=us-south1 --project_id=$PROJECT_ID < $SQL_FILE

    done
fi

TYPE="EDW_TRIPS_STAGE_APS"

if [[ $TYPE == "EDW_TRIPS_STAGE_APS" ]] 
then
    for SQL_FILE in $(ls -R ../EDW_TRIPS_STAGE_APS/*.sql)
    do 
        echo $SQL_FILE

        bq query --use_legacy_sql=false --location=us-south1 --project_id=$PROJECT_ID < $SQL_FILE

    done
fi