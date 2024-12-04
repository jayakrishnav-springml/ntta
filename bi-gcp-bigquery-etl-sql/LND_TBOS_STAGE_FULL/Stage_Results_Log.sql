## Translation time: 2024-03-04T06:44:00.523569Z
## Translation job ID: a86d938d-fa65-424d-bf4e-0008985e1778
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_TBOS/Tables/Stage_Results_Log.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_TBOS_STAGE_FULL.EIP_Results_Log
(
  transactionid INT64 NOT NULL,
  node STRING NOT NULL,
  groupid INT64 NOT NULL,
  groupsize INT64 NOT NULL,
  groupstageid INT64 NOT NULL,
  isvalidgroup INT64 NOT NULL,
  tranid STRING NOT NULL,
  agencycode STRING NOT NULL,
  roadid STRING NOT NULL,
  plazaid STRING NOT NULL,
  laneid STRING NOT NULL,
  vehicleclass STRING NOT NULL,
  transactiondate DATE NOT NULL,
  transactiontime INT64 NOT NULL,
  imageofrecordid INT64,
  disposition INT64,
  reasoncode INT64,
  timemir INT64 NOT NULL,
  platejurisdiction STRING,
  plateregistration STRING,
  platetypeprefix STRING,
  platetypesuffix STRING,
  alprjurisdiction STRING,
  alprregistration STRING,
  eipreceiveddate DATETIME,
  eipcompleteddate DATETIME,
  platesyntax STRING,
  statusid INT64,
  subreasontime INT64 NOT NULL,
  lastreviewer STRING,
  transactiontypeid INT64 NOT NULL,
  totalimgenhtime INT64 NOT NULL,
  reviewcount INT64 NOT NULL,
  cameraname STRING,
  cameraid STRING,
  isdayimage INT64,
  imagecontrast NUMERIC(31, 2),
  imagebrightness NUMERIC(31, 2),
  platereadconfidence INT64,
  iscommonsyntax INT64,
  signaturematchstatus INT64,
  cameraview STRING,
  isvalidgroupaip INT64,
  representativetranid INT64,
  platetype STRING,
  lnd_updatedate DATETIME,
  lnd_updatetype STRING,
  src_changedate DATETIME
)

CLUSTER BY TransactionID,TransactionTypeID
;