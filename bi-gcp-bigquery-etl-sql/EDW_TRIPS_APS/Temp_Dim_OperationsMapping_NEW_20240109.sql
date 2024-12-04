## Translation time: 2024-03-13T05:19:34.327071Z
## Translation job ID: 0a711804-adbe-4db7-8cda-d8808bd4ce52
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/NTTA_Missing_DDLs/EDW_TRIPS_Temp_Dim_OperationsMapping_NEW_20240109.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_TRIPS_APS.Dim_OperationsMapping_NEW_20240109
(
  tripidentmethod STRING,
  tripwith STRING,
  transactionpostingtype STRING,
  tripstagecode STRING,
  tripstatuscode STRING,
  reasoncode STRING,
  citationstagecode STRING,
  trippaymentstatusdesc STRING,
  sourcename STRING,
  operationsagency STRING,
  badaddressflag INT64 NOT NULL,
  nonrevenueflag INT64 NOT NULL,
  businessrulematchedflag INT64 NOT NULL,
  tripidentmethodid INT64 NOT NULL,
  tripidentmethodcode STRING NOT NULL,
  transactionpostingtypeid INT64,
  transactionpostingtypedesc STRING,
  tripstageid INT64,
  tripstagedesc STRING,
  tripstatusid INT64,
  tripstatusdesc STRING,
  reasoncodeid INT64,
  citationstageid INT64,
  citationstagedesc STRING,
  trippaymentstatusid INT64,
  trippaymentstatuscode STRING,
  edw_updatedate DATETIME
)
;