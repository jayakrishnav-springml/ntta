## Translation time: 2024-03-04T06:44:00.523569Z
## Translation job ID: a86d938d-fa65-424d-bf4e-0008985e1778
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_TBOS/Tables/Stage_ICN_Variance.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_TBOS_STAGE_FULL.TollPlus_ICN_Variance
(
  varianceid INT64 NOT NULL,
  icnid INT64 NOT NULL,
  varcashamt NUMERIC(31, 2),
  varcheckamt NUMERIC(31, 2),
  varmoamt NUMERIC(31, 2),
  varcreditamt NUMERIC(31, 2),
  varfloatamt NUMERIC(31, 2),
  varitemreturnedcnt INT64,
  varitemassigncnt INT64,
  varamttotal NUMERIC(31, 2),
  varitemtotal INT64,
  varcashiercheck NUMERIC(31, 2),
  systembalance NUMERIC(31, 2),
  csrenteredamount NUMERIC(31, 2),
  createddate DATETIME NOT NULL,
  createduser STRING,
  updateddate DATETIME NOT NULL,
  updateduser STRING,
  lnd_updatedate DATETIME,
  lnd_updatetype STRING,
  src_changedate DATETIME
)
CLUSTER BY 
varianceid
;