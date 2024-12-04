## Translation time: 2024-03-04T06:44:00.523569Z
## Translation job ID: a86d938d-fa65-424d-bf4e-0008985e1778
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_TBOS/Tables/Stage_UnmatchedTxnsQueue.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_TBOS_STAGE_FULL.TollPlus_UnmatchedTxnsQueue
(
  queueid INT64 NOT NULL,
  tripid INT64 NOT NULL,
  customerid INT64 NOT NULL,
  tocustomerid INT64 NOT NULL,
  transferstatusid INT64 NOT NULL,
  entrytolltxnid INT64 NOT NULL,
  exittolltxnid INT64 NOT NULL,
  entrytripdatetime DATETIME,
  exittripdatetime DATETIME,
  tripidentmethod STRING,
  tripchargetype STRING,
  entrylaneid INT64 NOT NULL,
  entryplazaid INT64 NOT NULL,
  exitlaneid INT64 NOT NULL,
  exitplazaid INT64 NOT NULL,
  vehiclenumber STRING,
  vehiclestate STRING,
  vehicleclass STRING,
  vehicleid INT64,
  tagrefid STRING,
  tollamount NUMERIC(31, 2) NOT NULL,
  feeamounts NUMERIC(31, 2) NOT NULL,
  discountsamount NUMERIC(31, 2) NOT NULL,
  outstandingamount NUMERIC(31, 2) NOT NULL,
  tripstageid INT64 NOT NULL,
  tripstatusid INT64 NOT NULL,
  tripstatusdate DATETIME NOT NULL,
  posteddate DATETIME,
  paymentstatusid INT64,
  tagtype STRING,
  transactiontypeid INT64,
  rewardsdiscountamount NUMERIC(31, 2),
  platetype STRING,
  disposition INT64,
  pbmtollamount NUMERIC(31, 2),
  avitollamount NUMERIC(31, 2),
  licenseplatecountry STRING,
  locationid INT64,
  agencyid INT64,
  netamount NUMERIC(31, 2),
  createddate DATETIME NOT NULL,
  createduser STRING NOT NULL,
  updateddate DATETIME NOT NULL,
  updateduser STRING NOT NULL,
  lnd_updatedate DATETIME,
  lnd_updatetype STRING,
  src_changedate DATETIME
)
CLUSTER BY queueid
;