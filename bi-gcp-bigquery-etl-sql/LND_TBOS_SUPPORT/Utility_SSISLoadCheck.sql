## Translation time: 2024-03-04T06:44:00.523569Z
## Translation job ID: a86d938d-fa65-424d-bf4e-0008985e1778
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_TBOS/Tables/Utility_SSISLoadCheck.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_TBOS_SUPPORT.SSISLoadCheck
(
  loaddate DATETIME NOT NULL,
  loadsource STRING NOT NULL,
  loadstep STRING NOT NULL ,
  loadinfo STRING NOT NULL,
  row_count INT64
);