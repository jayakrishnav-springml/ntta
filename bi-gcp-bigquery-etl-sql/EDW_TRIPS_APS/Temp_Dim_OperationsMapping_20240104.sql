## Translation time: 2024-03-13T05:19:34.327071Z
## Translation job ID: 0a711804-adbe-4db7-8cda-d8808bd4ce52
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/NTTA_Missing_DDLs/EDW_TRIPS_Temp_Dim_OperationsMapping_20240104.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_TRIPS_APS.Dim_OperationsMapping_20240104
(
  operationsmappingid INT64 NOT NULL,
  tripidentmethod STRING NOT NULL,
  tripwith STRING,
  transactionpostingtype STRING NOT NULL,
  tripstagecode STRING NOT NULL,
  tripstatuscode STRING NOT NULL,
  reasoncode STRING NOT NULL,
  citationstagecode STRING NOT NULL,
  trippaymentstatusdesc STRING NOT NULL,
  sourcename STRING,
  operationsagency STRING NOT NULL,
  badaddressflag INT64,
  nonrevenueflag INT64,
  businessrulematchedflag INT64,
  mapping STRING NOT NULL,
  mappingdetailed STRING NOT NULL,
  pursunpursstatus STRING NOT NULL,
  tripidentmethodid INT64 NOT NULL,
  tripidentmethodcode STRING NOT NULL,
  transactionpostingtypeid INT64 NOT NULL,
  transactionpostingtypedesc STRING NOT NULL,
  tripstageid INT64 NOT NULL,
  tripstagedesc STRING NOT NULL,
  tripstatusid INT64 NOT NULL,
  tripstatusdesc STRING NOT NULL,
  reasoncodeid INT64,
  citationstageid INT64 NOT NULL,
  citationstagedesc STRING NOT NULL,
  trippaymentstatusid INT64 NOT NULL,
  trippaymentstatuscode STRING NOT NULL,
  mstr_updateuser STRING,
  mstr_updatedate DATETIME,
  edw_updatedate DATETIME NOT NULL,
  backupdate DATETIME
)
CLUSTER BY 
operationsmappingid
;