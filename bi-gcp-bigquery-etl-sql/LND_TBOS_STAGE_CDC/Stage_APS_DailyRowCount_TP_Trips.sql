## Translation time: 2024-03-04T06:44:00.523569Z
## Translation job ID: a86d938d-fa65-424d-bf4e-0008985e1778
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_TBOS/Tables/Stage_APS_DailyRowCount_TP_Trips.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_TBOS_STAGE_CDC.APS_DailyRowCount_TP_Trips
(
  databasename STRING NOT NULL,
  tablename STRING NOT NULL,
  createddate DATE,
  drc_row_count INT64,
  dup_row_count INT64 NOT NULL,
  row_count INT64,
  lnd_updatedate DATETIME,
  src_changedate DATETIME
)
;