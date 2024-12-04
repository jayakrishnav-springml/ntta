## Translation time: 2024-03-04T06:41:57.683170Z
## Translation job ID: 00dc6676-2c12-444a-b02a-71c7788bdc89
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/EDW_TRIPS/Tables/dbo_Dim_OperationsMapping_ThisRun.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_TRIPS.Dim_OperationsMapping_ThisRun
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
CLUSTER BY operationsmappingid
;