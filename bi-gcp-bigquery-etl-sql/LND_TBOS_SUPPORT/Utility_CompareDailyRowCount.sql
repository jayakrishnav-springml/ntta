## Translation time: 2024-03-04T06:44:00.523569Z
## Translation job ID: a86d938d-fa65-424d-bf4e-0008985e1778
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_TBOS/Tables/Utility_CompareDailyRowCount.sql
## Translated from: SqlServer
## Translated to: BigQuery


CREATE TABLE IF NOT EXISTS LND_TBOS_SUPPORT.CompareDailyRowCount
(
  comparerunid INT64 NOT NULL,
  databasename STRING NOT NULL,
  tablename STRING NOT NULL,
  createddate DATE,
  src_rowcount INT64,
  aps_rowcount INT64,
  rowcountdiff INT64,
  diffpercent NUMERIC(35, 6),
  src_rowcountdate DATETIME,
  aps_rowcountdate DATETIME,
  lnd_updatedate DATETIME
) cluster by comparerunid ;