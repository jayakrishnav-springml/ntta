## Translation time: 2024-03-04T06:44:00.523569Z
## Translation job ID: a86d938d-fa65-424d-bf4e-0008985e1778
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_TBOS/Tables/Stage_ViolatorCollectionsAgencyTracker.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_TBOS_STAGE_FULL.TER_ViolatorCollectionsAgencyTracker
(
  viocollagencytrackerid INT64 NOT NULL,
  violatorid INT64,
  agency STRING,
  phase INT64,
  previousagency STRING,
  isactive INT64,
  channelid INT64,
  icnid INT64,
  createddate DATETIME,
  createduser STRING,
  updateddate DATETIME,
  updateduser STRING,
  lnd_updatedate DATETIME,
  lnd_updatetype STRING,
  src_changedate DATETIME
)
CLUSTER BY viocollagencytrackerid
;