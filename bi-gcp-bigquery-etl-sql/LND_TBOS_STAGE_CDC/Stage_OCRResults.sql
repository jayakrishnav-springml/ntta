## Translation time: 2024-03-04T06:44:00.523569Z
## Translation job ID: a86d938d-fa65-424d-bf4e-0008985e1778
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_TBOS/Tables/Stage_OCRResults.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_TBOS_STAGE_CDC.EIP_OCRResults
(
  ocrresultid INT64 NOT NULL,
  transactionid INT64,
  txnimageid INT64,
  ocrresultindex INT64 NOT NULL,
  plateconfidence INT64 NOT NULL,
  plateregistration STRING,
  registrationreadconfidence INT64,
  platejurisdiction STRING,
  jurisdictionreadconfidence INT64,
  platecharheight INT64,
  plateloactionright INT64,
  plateloactionleft INT64,
  plateloactiontop INT64,
  plateloactionbottom INT64,
  platecharresults STRING,
  platevsrneeded INT64,
  disposition INT64,
  reasoncode INT64,
  createddate DATETIME,
  createduser STRING,
  updateddate DATETIME,
  updateduser STRING,
  lnd_updatedate DATETIME,
  lnd_updatetype STRING,
  src_changedate DATETIME
)
cluster by ocrresultid
;