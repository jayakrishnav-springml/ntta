## Translation time: 2024-03-04T06:41:57.683170Z
## Translation job ID: 00dc6676-2c12-444a-b02a-71c7788bdc89
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/EDW_TRIPS/Tables/dbo_Fact_Violation.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_TRIPS_APS.Fact_Violation
(
  citationid INT64 NOT NULL,
  tptripid INT64 NOT NULL,
  tripdayid INT64 NOT NULL,
  laneid INT64 NOT NULL,
  customerid INT64 NOT NULL,
  custrefid INT64 NOT NULL,
  vehicleid INT64 NOT NULL,
  accountagencyid INT64 NOT NULL,
  tripstatusid INT64 NOT NULL,
  tripstageid INT64 NOT NULL,
  transactiontypeid INT64 NOT NULL,
  transactionpostingtypeid INT64 NOT NULL,
  citationstageid INT64 NOT NULL,
  paymentstatusid INT64 NOT NULL,
  vehicleclassid INT64 NOT NULL,
  sourceofentry INT64 NOT NULL,
  tripdate DATETIME NOT NULL,
  tripstatusdate DATETIME NOT NULL,
  posteddate DATETIME NOT NULL,
  writeoffdate DATETIME NOT NULL,
  writeoffflag INT64 NOT NULL,
  currenttxnflag INT64 NOT NULL,
  deleteflag INT64 NOT NULL,
  tollamount NUMERIC(31, 2) NOT NULL,
  feeamount NUMERIC(31, 2) NOT NULL,
  outstandingamount NUMERIC(31, 2) NOT NULL,
  netamount NUMERIC(31, 2) NOT NULL,
  pbmtollamount NUMERIC(31, 2) NOT NULL,
  avitollamount NUMERIC(31, 2) NOT NULL,
  writeoffamount NUMERIC(31, 2) NOT NULL,
  updateddate DATETIME NOT NULL,
  lnd_updatedate DATETIME NOT NULL,
  edw_updatedate DATETIME NOT NULL,
  transactiondate DATETIME
)
;