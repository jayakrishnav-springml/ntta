#!/bin/bash

echo "Scripts to create views for EDW_TRIPS datasets"

# Replace with working project_id
# export PROJECT_ID='prj-ntta-ops-bi-devt-svc-01'
# export PROJECT_ID='ntta-gcp-poc'
PROJECT_ID="$1"

if [ -z "$1" ]; then
    echo "Warning: Project id not found. Please provide a valid project ID as parameter. "
    echo "./deploy_views_EDW_TRIPS.sh  <PROJECT_ID>"
    exit 1
fi

bq query --use_legacy_sql=false --location=us-south1 --project_id=$PROJECT_ID < ../EDW_TRIPS/Views/dbo_DIM_MONTH_TXN_VW.sql
bq query --use_legacy_sql=false --location=us-south1 --project_id=$PROJECT_ID < ../EDW_TRIPS/Views/dbo_ExcusalDetailReport.sql
bq query --use_legacy_sql=false --location=us-south1 --project_id=$PROJECT_ID < ../EDW_TRIPS/Views/dbo_F_BUBBLE_TARGET_MAIN_CURR_VW.sql
bq query --use_legacy_sql=false --location=us-south1 --project_id=$PROJECT_ID < ../EDW_TRIPS/Views/dbo_vw_Bankruptcy.sql
bq query --use_legacy_sql=false --location=us-south1 --project_id=$PROJECT_ID < ../EDW_TRIPS/Views/dbo_vw_BubbleSummarySnapshot.sql
bq query --use_legacy_sql=false --location=us-south1 --project_id=$PROJECT_ID < ../EDW_TRIPS/Views/dbo_vw_BubbleSummarySnapshot_OldNames.sql
bq query --use_legacy_sql=false --location=us-south1 --project_id=$PROJECT_ID < ../EDW_TRIPS/Views/dbo_vw_CustomerTagSummary.sql
bq query --use_legacy_sql=false --location=us-south1 --project_id=$PROJECT_ID < ../EDW_TRIPS/Views/dbo_vw_Fact_PaymentDetail.sql
bq query --use_legacy_sql=false --location=us-south1 --project_id=$PROJECT_ID < ../EDW_TRIPS/Views/dbo_vw_Fact_VRB.sql
bq query --use_legacy_sql=false --location=us-south1 --project_id=$PROJECT_ID < ../EDW_TRIPS/Views/dbo_vw_GL_IOP_UnidentifiedAgingTxn.sql
bq query --use_legacy_sql=false --location=us-south1 --project_id=$PROJECT_ID < ../EDW_TRIPS/Views/Reporting_vw_Dim_Month_Txn.sql
bq query --use_legacy_sql=false --location=us-south1 --project_id=$PROJECT_ID < ../EDW_TRIPS/Views/dbo_vw_CustomerSentDocumentsDailySummary.sql