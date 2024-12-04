## Translation time: 2024-03-04T06:41:57.683170Z
## Translation job ID: 00dc6676-2c12-444a-b02a-71c7788bdc89
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/EDW_TRIPS/Tables/Stage_Dim_OperationsMapping_NEW.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_TRIPS_STAGE.Dim_OperationsMapping_NEW
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