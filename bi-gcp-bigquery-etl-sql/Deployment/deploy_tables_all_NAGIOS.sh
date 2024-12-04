#!/bin/bash

echo "Scripts to create Tables/schema for NAGIOS datasets"

# Replace with working project_id
# export PROJECT_ID='prj-ntta-ops-bi-devt-svc-01'
# export PROJECT_ID='ntta-gcp-poc'
PROJECT_ID="$1"

if [ -z "$1" ]; then
    echo "Warning: Project id not found. Please provide a valid project ID as parameter. "
    echo "./deploy_tables_EDW_NAGIOS.sh  <PROJECT_ID>"
    exit 1
fi


TYPE="EDW_NAGIOS"

if [[ $TYPE == "EDW_NAGIOS" ]] 
then
    for SQL_FILE in $(ls -R ../EDW_NAGIOS/*.sql)
    do 
        echo $SQL_FILE

        bq query --use_legacy_sql=false --location=us-south1 --project_id=$PROJECT_ID < $SQL_FILE

    done
fi


TYPE="EDW_NAGIOS_SUPPORT"

if [[ $TYPE == "EDW_NAGIOS_SUPPORT" ]] 
then
    for SQL_FILE in $(ls -R ../EDW_NAGIOS_SUPPORT/*.sql)
    do 
        echo $SQL_FILE

        bq query --use_legacy_sql=false --location=us-south1 --project_id=$PROJECT_ID < $SQL_FILE

    done
fi


TYPE="EDW_NAGIOS_STAGE"

if [[ $TYPE == "EDW_NAGIOS_STAGE" ]] 
then
    for SQL_FILE in $(ls -R ../EDW_NAGIOS_STAGE/*.sql)
    do 
        echo $SQL_FILE

        bq query --use_legacy_sql=false --location=us-south1 --project_id=$PROJECT_ID < $SQL_FILE

    done
fi


TYPE="EDW_NAGIOS_DELETE"

if [[ $TYPE == "EDW_NAGIOS_DELETE" ]] 
then
    for SQL_FILE in $(ls -R ../EDW_NAGIOS_DELETE/*.sql)
    do 
        echo $SQL_FILE

        bq query --use_legacy_sql=false --location=us-south1 --project_id=$PROJECT_ID < $SQL_FILE

    done
fi


TYPE="EDW_NAGIOS_APS"

if [[ $TYPE == "EDW_NAGIOS_APS" ]] 
then
    for SQL_FILE in $(ls -R ../EDW_NAGIOS_APS/*.sql)
    do 
        echo $SQL_FILE

        bq query --use_legacy_sql=false --location=us-south1 --project_id=$PROJECT_ID < $SQL_FILE

    done
fi


TYPE="EDW_NAGIOS_STAGE_APS"

if [[ $TYPE == "EDW_NAGIOS_STAGE_APS" ]] 
then
    for SQL_FILE in $(ls -R ../EDW_NAGIOS_STAGE_APS/*.sql)
    do 
        echo $SQL_FILE

        bq query --use_legacy_sql=false --location=us-south1 --project_id=$PROJECT_ID < $SQL_FILE

    done
fi

TYPE="LND_NAGIOS"

if [[ $TYPE == "LND_NAGIOS" ]] 
then
    for SQL_FILE in $(ls -R ../LND_NAGIOS/*.sql)
    do 
        echo $SQL_FILE

        bq query --use_legacy_sql=false --location=us-south1 --project_id=$PROJECT_ID < $SQL_FILE

    done
fi

TYPE="LND_NAGIOS_SUPPORT"

if [[ $TYPE == "LND_NAGIOS_SUPPORT" ]] 
then
    for SQL_FILE in $(ls -R ../LND_NAGIOS_SUPPORT/*.sql)
    do 
        echo $SQL_FILE

        bq query --use_legacy_sql=false --location=us-south1 --project_id=$PROJECT_ID < $SQL_FILE

    done
fi

TYPE="LND_NAGIOS_STAGE_CDC"

if [[ $TYPE == "LND_NAGIOS_STAGE_CDC" ]] 
then
    for SQL_FILE in $(ls -R ../LND_NAGIOS_STAGE_CDC/*.sql)
    do 
        echo $SQL_FILE

        bq query --use_legacy_sql=false --location=us-south1 --project_id=$PROJECT_ID < $SQL_FILE

    done
fi

TYPE="LND_NAGIOS_STAGE_FULL"

if [[ $TYPE == "LND_NAGIOS_STAGE_FULL" ]] 
then
    for SQL_FILE in $(ls -R ../LND_NAGIOS_STAGE_FULL/*.sql)
    do 
        echo $SQL_FILE

        bq query --use_legacy_sql=false --location=us-south1 --project_id=$PROJECT_ID < $SQL_FILE

    done
fi