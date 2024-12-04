## Translation time: 2024-03-04T06:44:00.523569Z
## Translation job ID: a86d938d-fa65-424d-bf4e-0008985e1778
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_TBOS/Tables/Utility_LoadProcessControl.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_TBOS_SUPPORT.LoadProcessControl
(
  tablename STRING,
  lastupdateddate DATETIME,
  rowupdatedate DATETIME
)
;