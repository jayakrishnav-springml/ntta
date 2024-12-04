## Translation time: 2024-03-04T06:41:57.683170Z
## Translation job ID: 00dc6676-2c12-444a-b02a-71c7788bdc89
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/EDW_TRIPS/Tables/Ref_OperationsMapping_XL.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_TRIPS_SUPPORT.OperationsMapping_XL
(
  unique_xl_opsmappingid INT64,
  rn INT64,
  asofdayid INT64,
  tripidentmethod STRING,
  tripwith STRING,
  transactionpostingtype STRING,
  tripstageid INT64,
  tripstagecode STRING,
  tripstatusid INT64,
  tripstatuscode STRING,
  reasoncode STRING,
  citationstagecode STRING,
  trippaymentstatusid INT64,
  trippaymentstatusdesc STRING,
  sourcename STRING,
  operationsagency STRING NOT NULL,
  badaddressflag INT64,
  nonrevenueflag INT64,
  businessrulematchedflag INT64,
  mapping STRING,
  mappingdetailed STRING,
  pursunpursstatus STRING
)
;