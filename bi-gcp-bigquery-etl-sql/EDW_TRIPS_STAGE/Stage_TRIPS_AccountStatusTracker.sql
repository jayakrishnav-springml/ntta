## Translation time: 2024-03-04T06:41:57.683170Z
## Translation job ID: 00dc6676-2c12-444a-b02a-71c7788bdc89
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/EDW_TRIPS/Tables/Stage_TRIPS_AccountStatusTracker.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_TRIPS_STAGE.TRIPS_AccountStatusTracker
(
  customerid INT64,
  datasource STRING NOT NULL,
  tablesource STRING NOT NULL,
  customerstatusdesc STRING,
  accounttypeid INT64,
  accounttypecode STRING,
  accounttypedesc STRING,
  accountstatusid INT64,
  accountstatuscode STRING,
  accountstatusdesc STRING,
  accountstatusdate DATETIME,
  createddate DATETIME NOT NULL,
  createduser STRING,
  updateddate DATETIME NOT NULL,
  updateduser STRING,
  channelid INT64,
  icnid INT64,
  employeeid INT64,
  employeename STRING,
  posid INT64,
  trips_accstatushistid INT64,
  trips_histid INT64
) CLUSTER BY customerid
;