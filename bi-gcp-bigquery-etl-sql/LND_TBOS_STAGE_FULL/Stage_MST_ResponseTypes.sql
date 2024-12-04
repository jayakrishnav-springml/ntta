## Translation time: 2024-03-04T06:44:00.523569Z
## Translation job ID: a86d938d-fa65-424d-bf4e-0008985e1778
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_TBOS/Tables/Stage_MST_ResponseTypes.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_TBOS_STAGE_FULL.MIR_MST_ResponseTypes
(
  responsetypeid INT64,
  responsetype STRING,
  createddate DATETIME NOT NULL,
  createduser STRING NOT NULL,
  lnd_updatedate DATETIME,
  lnd_updatetype STRING,
  src_changedate DATETIME
)
cluster by responsetypeid
;