## Translation time: 2024-03-04T06:41:57.683170Z
## Translation job ID: 00dc6676-2c12-444a-b02a-71c7788bdc89
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/EDW_TRIPS/Tables/dbo_Fact_TollTransaction_NEW.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_TRIPS.Fact_TollTransaction_NEW
(
  custtripid INT64 NOT NULL,
  tptripid INT64 NOT NULL,
  tripdayid INT64 NOT NULL,
  laneid INT64 NOT NULL,
  customerid INT64 NOT NULL,
  vehicleid INT64 NOT NULL,
  custtagid INT64 NOT NULL,
  vehicletagid INT64 NOT NULL,
  vehicleclassid INT64 NOT NULL,
  paymentstatusid INT64 NOT NULL,
  tripstageid INT64 NOT NULL,
  tripstatusid INT64 NOT NULL,
  tripidentmethodid INT64 NOT NULL,
  transactionpostingtypeid INT64 NOT NULL,
  sourceofentry INT64 NOT NULL,
  tripdate DATETIME NOT NULL,
  posteddate DATETIME NOT NULL,
  tripstatusdate DATETIME NOT NULL,
  adjusteddate DATETIME NOT NULL,
  currenttxnflag INT64 NOT NULL,
  deleteflag INT64 NOT NULL,
  tollamount NUMERIC(31, 2) NOT NULL,
  feeamount NUMERIC(31, 2) NOT NULL,
  discountamount NUMERIC(31, 2) NOT NULL,
  netamount NUMERIC(31, 2) NOT NULL,
  rewarddiscountamount NUMERIC(31, 2) NOT NULL,
  outstandingamount NUMERIC(31, 2) NOT NULL,
  pbmtollamount NUMERIC(31, 2) NOT NULL,
  avitollamount NUMERIC(31, 2) NOT NULL,
  adjustedtollamount NUMERIC(31, 2) NOT NULL,
  updateddate DATETIME NOT NULL,
  lnd_updatedate DATETIME NOT NULL,
  edw_updatedate DATETIME NOT NULL,
  txndatetime DATETIME NOT NULL,
  feeamounts NUMERIC(31, 2) NOT NULL,
  adjustedtolls NUMERIC(31, 2) NOT NULL,
  tripidentmethod STRING,
  rewardsdiscountamount NUMERIC(31, 2),
  discountsamount NUMERIC(31, 2) NOT NULL
)
cluster by custtripid
;