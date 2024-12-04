## Translation time: 2024-03-04T06:41:57.683170Z
## Translation job ID: 00dc6676-2c12-444a-b02a-71c7788bdc89
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/EDW_TRIPS/Tables/Ref_RITE_AccountStatusHistory.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_TRIPS_SUPPORT.RITE_AccountStatusHistory
(
  datasource STRING NOT NULL,
  tablesource STRING NOT NULL,
  customerid NUMERIC(29),
  acct_status_code STRING,
  accountstatusid INT64,
  accountstatusdate DATETIME,
  createddate DATETIME,
  createduser STRING,
  updateddate DATETIME,
  updateduser STRING,
  rite_acct_hist_seq INT64 NOT NULL,
  rite_histlast_rn INT64
)
cluster by customerid
;