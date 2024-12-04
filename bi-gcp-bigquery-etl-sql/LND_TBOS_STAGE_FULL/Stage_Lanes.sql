## Translation time: 2024-03-04T06:44:00.523569Z
## Translation job ID: a86d938d-fa65-424d-bf4e-0008985e1778
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_TBOS/Tables/Stage_Lanes.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_TBOS_STAGE_FULL.TollPlus_Lanes
(
  laneid INT64 NOT NULL,
  lanecode STRING NOT NULL,
  plazaid INT64 NOT NULL,
  lanename STRING NOT NULL,
  lanetype STRING NOT NULL,
  description STRING NOT NULL,
  lanestatus STRING NOT NULL,
  direction STRING,
  lanecategoryid INT64,
  exitlanecode STRING,
  channelid INT64,
  icnid INT64,
  createddate DATETIME NOT NULL,
  createduser STRING NOT NULL,
  updateddate DATETIME NOT NULL,
  updateduser STRING NOT NULL,
  lnd_updatedate DATETIME,
  lnd_updatetype STRING,
  src_changedate DATETIME
)
cluster by laneid
;