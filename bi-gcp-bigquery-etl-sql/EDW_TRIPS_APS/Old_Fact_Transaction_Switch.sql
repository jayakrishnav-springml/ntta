## Translation time: 2024-03-04T06:41:57.683170Z
## Translation job ID: 00dc6676-2c12-444a-b02a-71c7788bdc89
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/EDW_TRIPS/Tables/Old_Fact_Transaction_Switch.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_TRIPS_APS.Fact_Transaction_Switch
(
  tptripid INT64 NOT NULL,
  tripdayid INT64 NOT NULL,
  laneid INT64 NOT NULL,
  tripstageid INT64 NOT NULL,
  tripstatusid INT64 NOT NULL,
  paymentstatusid INT64 NOT NULL,
  sourcetripid INT64 NOT NULL,
  linkid INT64 NOT NULL,
  vehicleid INT64 NOT NULL,
  tagagencyid INT64 NOT NULL,
  transactionpostingtypeid INT64 NOT NULL,
  ipstransactionid INT64 NOT NULL,
  reasoncodeid INT64 NOT NULL,
  vehicleclassid INT64 NOT NULL,
  tagvehicleclassid INT64 NOT NULL,
  tripidentmethodid INT64 NOT NULL,
  sourceofentry INT64 NOT NULL,
  recordtype STRING NOT NULL,
  recordnumber INT64 NOT NULL,
  vehiclespeed INT64 NOT NULL,
  disposition STRING NOT NULL,
  tripwith STRING NOT NULL,
  tripdate DATETIME NOT NULL,
  tripstatusdate DATE NOT NULL,
  posteddate DATE NOT NULL,
  nonrevenueflag INT64 NOT NULL,
  deleteflag INT64 NOT NULL,
  tollamount NUMERIC(31, 2) NOT NULL,
  feeamount NUMERIC(31, 2) NOT NULL,
  receivedtollamount NUMERIC(31, 2) NOT NULL,
  outstandingamount NUMERIC(31, 2) NOT NULL,
  pbmtollamount NUMERIC(31, 2) NOT NULL,
  avitollamount NUMERIC(31, 2) NOT NULL,
  updateddate DATETIME NOT NULL,
  lnd_updatedate DATETIME NOT NULL,
  edw_updatedate DATETIME NOT NULL
)
;