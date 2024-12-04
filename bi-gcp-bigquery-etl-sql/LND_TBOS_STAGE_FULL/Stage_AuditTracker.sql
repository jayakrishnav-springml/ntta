## Translation time: 2024-03-04T06:44:00.523569Z
## Translation job ID: a86d938d-fa65-424d-bf4e-0008985e1778
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_TBOS/Tables/Stage_AuditTracker.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_TBOS_STAGE_FULL.EIP_AuditTracker
(
  auditsetupid INT64 NOT NULL,
  auditname STRING,
  audittype INT64 NOT NULL,
  auditstatus INT64 NOT NULL,
  audittrancount INT64,
  startdate DATETIME,
  enddate DATETIME,
  auditvalidtill DATETIME,
  auditstatusdate DATETIME,
  qualifiedtxnscnt INT64,
  createddate DATETIME NOT NULL,
  createduser STRING NOT NULL,
  updateddate DATETIME NOT NULL,
  updateduser STRING NOT NULL,
  lnd_updatedate DATETIME,
  lnd_updatetype STRING,
  src_changedate DATETIME
)cluster by auditsetupid
;