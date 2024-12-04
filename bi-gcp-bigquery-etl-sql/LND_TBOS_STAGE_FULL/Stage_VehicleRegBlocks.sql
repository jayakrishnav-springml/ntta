## Translation time: 2024-03-04T06:44:00.523569Z
## Translation job ID: a86d938d-fa65-424d-bf4e-0008985e1778
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_TBOS/Tables/Stage_VehicleRegBlocks.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_TBOS_STAGE_FULL.TER_VehicleRegBlocks
(
  vrbid INT64 NOT NULL,
  hvid INT64,
  isactive INT64 NOT NULL,
  statuslookupid INT64,
  vrbagencylookupid INT64,
  requesteddate DATETIME,
  placeddate DATETIME,
  rejectiondate DATETIME,
  vrbrejectlookupid INT64,
  removerequesteddate DATETIME,
  removerejectiondate DATETIME,
  vrbremovalrejectionlookupid INT64,
  removeddate DATETIME,
  vrbremovallookupid INT64,
  retrycount INT64,
  createddate DATETIME,
  createduser STRING,
  updateddate DATETIME,
  updateduser STRING,
  lnd_updatedate DATETIME,
  lnd_updatetype STRING,
  src_changedate DATETIME
)
CLUSTER BY vrbid
;