## Translation time: 2024-03-04T06:44:00.523569Z
## Translation job ID: a86d938d-fa65-424d-bf4e-0008985e1778
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_TBOS/Tables/Finance_TollAdjustments.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_TBOS.Finance_TollAdjustments
(
  tolladjustmentid INT64 NOT NULL,
  adjustmenttype STRING,
  adjustmenttypedesc STRING,
  isactive INT64,
  parentadjustmenttype STRING,
  parentadjustmenttypedesc STRING,
  isntta INT64 NOT NULL,
  istsa INT64 NOT NULL,
  isdalordfw INT64 NOT NULL,
  isiop INT64 NOT NULL,
  isiopawayntta INT64 NOT NULL,
  isiopawaytsa INT64 NOT NULL,
  isonlyinbound INT64 NOT NULL,
  isonlythroughcase INT64 NOT NULL,
  createddate DATETIME,
  createduser STRING,
  updateddate DATETIME,
  updateduser STRING,
  lnd_updatedate DATETIME,
  lnd_updatetype STRING,
  src_changedate DATETIME
)
CLUSTER BY
tolladjustmentid
;