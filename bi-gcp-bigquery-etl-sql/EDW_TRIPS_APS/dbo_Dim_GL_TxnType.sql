## Translation time: 2024-03-04T06:41:57.683170Z
## Translation job ID: 00dc6676-2c12-444a-b02a-71c7788bdc89
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/EDW_TRIPS/Tables/dbo_Dim_GL_TxnType.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_TRIPS_APS.Dim_GL_TxnType
(
  txntypeid INT64 NOT NULL,
  txntype STRING NOT NULL,
  txndesc STRING,
  txntype_categoryid INT64 NOT NULL,
  statementnote STRING,
  customernote STRING,
  violatornote STRING,
  isautomatic INT64 NOT NULL,
  adjustmentcategoryid INT64,
  levelid INT64 NOT NULL,
  status STRING,
  levelcode STRING,
  businessunitid INT64,
  createddate DATETIME NOT NULL,
  createduser STRING,
  updateddate DATETIME NOT NULL,
  updateduser STRING,
  edw_updatedate TIMESTAMP NOT NULL
)
CLUSTER BY txntypeid
;