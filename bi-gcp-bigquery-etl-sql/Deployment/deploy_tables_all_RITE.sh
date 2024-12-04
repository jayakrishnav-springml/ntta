#!/bin/bash

echo "Scripts to create Tables/schema for all RITE datasets"

# Replace with working project_id
# export PROJECT_ID='prj-ntta-ops-bi-devt-svc-01'
# export PROJECT_ID='ntta-gcp-poc'
PROJECT_ID="$1"

if [ -z "$1" ]; then
    echo "Warning: Project id not found. Please provide a valid project ID as parameter. "
    echo "./deploy_tables_all_RITE.sh  <PROJECT_ID>"
    exit 1
fi


TYPE="EDW_RITE"

if [[ $TYPE == "EDW_RITE" ]] 
then
    for SQL_FILE in $(ls -R ../EDW_RITE/*.sql)
    do 
        echo $SQL_FILE

        bq query --use_legacy_sql=false --location=us-south1 --project_id=$PROJECT_ID < $SQL_FILE

    done
fi


TYPE="EDW_TER"

if [[ $TYPE == "EDW_TER" ]] 
then
    for SQL_FILE in $(ls -R ../EDW_TER/*.sql)
    do 
        echo $SQL_FILE

        bq query --use_legacy_sql=false --location=us-south1 --project_id=$PROJECT_ID < $SQL_FILE

    done
fi

TYPE="LND_LG_DMV"

if [[ $TYPE == "LND_LG_DMV" ]] 
then
    for SQL_FILE in $(ls -R ../LND_LG_DMV/*.sql)
    do 
        echo $SQL_FILE

        bq query --use_legacy_sql=false --location=us-south1 --project_id=$PROJECT_ID < $SQL_FILE

    done
fi


TYPE="LND_LG_HOST"

if [[ $TYPE == "LND_LG_HOST" ]] 
then
    for SQL_FILE in $(ls -R ../LND_LG_HOST/*.sql)
    do 
        echo $SQL_FILE

        bq query --use_legacy_sql=false --location=us-south1 --project_id=$PROJECT_ID < $SQL_FILE

    done
fi


TYPE="LND_LG_ICRS"

if [[ $TYPE == "LND_LG_ICRS" ]] 
then
    for SQL_FILE in $(ls -R ../LND_LG_ICRS/*.sql)
    do 
        echo $SQL_FILE

        bq query --use_legacy_sql=false --location=us-south1 --project_id=$PROJECT_ID < $SQL_FILE

    done
fi

TYPE="LND_LG_IOP"

if [[ $TYPE == "LND_LG_IOP" ]] 
then
    for SQL_FILE in $(ls -R ../LND_LG_IOP/*.sql)
    do 
        echo $SQL_FILE

        bq query --use_legacy_sql=false --location=us-south1 --project_id=$PROJECT_ID < $SQL_FILE

    done
fi

TYPE="LND_LG_TS"

if [[ $TYPE == "LND_LG_TS" ]] 
then
    for SQL_FILE in $(ls -R ../LND_LG_TS/*.sql)
    do 
        echo $SQL_FILE

        bq query --use_legacy_sql=false --location=us-south1 --project_id=$PROJECT_ID < $SQL_FILE

    done
fi

TYPE="LND_LG_VPS"

if [[ $TYPE == "LND_LG_VPS" ]] 
then
    for SQL_FILE in $(ls -R ../LND_LG_VPS/*.sql)
    do 
        echo $SQL_FILE

        bq query --use_legacy_sql=false --location=us-south1 --project_id=$PROJECT_ID < $SQL_FILE

    done
fi

TYPE="LND_TER"

if [[ $TYPE == "LND_TER" ]] 
then
    for SQL_FILE in $(ls -R ../LND_TER/*.sql)
    do 
        echo $SQL_FILE

        bq query --use_legacy_sql=false --location=us-south1 --project_id=$PROJECT_ID < $SQL_FILE

    done
fi


