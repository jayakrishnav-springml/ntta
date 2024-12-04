## Translation time: 2024-03-04T06:44:00.523569Z
## Translation job ID: a86d938d-fa65-424d-bf4e-0008985e1778
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_TBOS/Tables/Stage_ReasonCodesHistory.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_TBOS_STAGE_CDC.MIR_ReasonCodesHistory
(
  reasoncodeid INT64 NOT NULL,
  reasoncode STRING,
  reasoncodedesc STRING,
  shortcutkey STRING,
  parentid INT64 NOT NULL,
  histid INT64 NOT NULL,
  action STRING,
  actiondatetime DATETIME,
  changessummary STRING,
  createddate DATETIME,
  createduser STRING,
  updateddate DATETIME,
  updateduser STRING,
  lnd_updatedate DATETIME,
  lnd_updatetype STRING,
  src_changedate DATETIME
)
cluster by histid
;