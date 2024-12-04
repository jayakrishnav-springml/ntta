## Translation time: 2024-03-04T06:41:57.683170Z
## Translation job ID: 00dc6676-2c12-444a-b02a-71c7788bdc89
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/EDW_TRIPS/Tables/dbo_Dim_ChartOfAccounts.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_TRIPS_APS.Dim_ChartOfAccounts
(
  surrogate_coaid INT64 NOT NULL,
  chartofaccountid INT64 NOT NULL,
  accountname STRING,
  parentchartofaccountid INT64,
  agcode STRING NOT NULL,
  asgcode STRING NOT NULL,
  lowerbound INT64,
  upperbound INT64,
  status STRING,
  iscontrolaccount STRING,
  normalbalancetype STRING,
  legalaccountid INT64,
  agencycode STRING,
  starteffectivedate DATETIME,
  endeffectivedate DATETIME,
  comments STRING,
  isdeleted INT64 NOT NULL,
  createddate DATETIME NOT NULL,
  createduser STRING,
  updateddate DATETIME NOT NULL,
  updateduser STRING,
  edw_updatedate TIMESTAMP NOT NULL
)
CLUSTER BY chartofaccountid
;