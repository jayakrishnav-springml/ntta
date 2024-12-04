## Translation time: 2024-03-04T06:44:00.523569Z
## Translation job ID: a86d938d-fa65-424d-bf4e-0008985e1778
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_TBOS/Tables/Stage_Request_Tracker.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_TBOS_STAGE_FULL.EIP_Request_Tracker
(
  trackerid INT64 NOT NULL,
  node STRING NOT NULL,
  groupid INT64 NOT NULL,
  groupsize INT64 NOT NULL,
  isvalidgroup INT64 NOT NULL,
  agencycode STRING NOT NULL,
  plazaid STRING NOT NULL,
  laneid STRING NOT NULL,
  tranid STRING NOT NULL,
  transactiondate DATE NOT NULL,
  transactiontime INT64 NOT NULL,
  eipreceiveddate DATETIME NOT NULL,
  transactionid INT64 NOT NULL,
  reptransactionid INT64 NOT NULL,
  request_history STRING,
  process_status INT64 NOT NULL,
  pending_aiprequest STRING,
  stageid INT64 NOT NULL,
  queueid INT64 NOT NULL,
  imageid INT64,
  iseasilyconfused INT64 NOT NULL,
  vehicleclass STRING NOT NULL,
  imageavailability INT64,
  registrationmask STRING,
  plateregistration STRING,
  platejurisdiction STRING,
  platetypeprefix STRING,
  platetypesuffix STRING,
  roihorizontalposition INT64,
  roihorizontalsize INT64,
  roiverticalposition INT64,
  roiverticalsize INT64,
  dispositioncode INT64,
  unreadreasoncode INT64,
  completiondate DATETIME,
  subreasontime INT64,
  lastreviewer STRING,
  transactiontypeid INT64,
  totalimgenhtime INT64,
  totalmirtime INT64,
  reviewcount INT64,
  responsesenddate DATETIME,
  retrycount INT64,
  responsestatus STRING,
  workqueuedate DATETIME,
  platetype STRING,
  createddate DATETIME NOT NULL,
  updateddate DATETIME,
  lnd_updatedate DATETIME,
  lnd_updatetype STRING,
  src_changedate DATETIME
)

CLUSTER BY TrackerID
;