## Translation time: 2024-03-04T06:44:00.523569Z
## Translation job ID: a86d938d-fa65-424d-bf4e-0008985e1778
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_TBOS/Tables/TollPlus_ICN_Cash.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_TBOS.TollPlus_ICN_Cash
(
  icn_cashid INT64 NOT NULL,
  icnid INT64 NOT NULL,
  nickle INT64,
  onecoin INT64,
  penny INT64,
  dimes INT64,
  quarter INT64,
  half INT64,
  one INT64,
  two INT64,
  five INT64,
  ten INT64,
  twenty INT64,
  fifty INT64,
  hundred INT64,
  type STRING,
  createddate DATETIME NOT NULL,
  createduser STRING,
  updateduser STRING,
  updateddate DATETIME NOT NULL,
  lnd_updatedate DATETIME,
  lnd_updatetype STRING,
  src_changedate DATETIME
)
cluster by icn_cashid
;