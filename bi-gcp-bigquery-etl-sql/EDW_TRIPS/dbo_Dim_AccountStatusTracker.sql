## Translation time: 2024-03-04T06:41:57.683170Z
## Translation job ID: 00dc6676-2c12-444a-b02a-71c7788bdc89
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/EDW_TRIPS/Tables/dbo_Dim_AccountStatusTracker.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_TRIPS.Dim_AccountStatusTracker
(
  customerid NUMERIC(29),
  accountstatusseq INT64,
  datasource STRING NOT NULL,
  tablesource STRING NOT NULL,
  customerstatusdesc STRING,
  accounttypeid INT64,
  accounttypedesc STRING,
  accountstatusid INT64,
  accountstatusdesc STRING,
  accountstatusstartdate DATETIME,
  accountstatusenddate DATETIME NOT NULL,
  createddate DATETIME,
  createduser STRING,
  updateddate DATETIME,
  updateduser STRING,
  employeeid INT64,
  username STRING,
  channelid INT64,
  channelname STRING,
  channeldesc STRING,
  posid INT64,
  icnid INT64,
  rite_acct_hist_seq INT64,
  trips_accstatushistid INT64,
  trips_histid INT64,
  rownumfromfirst INT64,
  rownumfromlast INT64,
  edw_updatedate DATETIME
)
CLUSTER BY customerid
;