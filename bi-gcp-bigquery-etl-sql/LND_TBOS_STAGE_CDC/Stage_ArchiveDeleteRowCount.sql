## Translation time: 2024-03-04T06:44:00.523569Z
## Translation job ID: a86d938d-fa65-424d-bf4e-0008985e1778
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_TBOS/Tables/Stage_ArchiveDeleteRowCount.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_TBOS_STAGE_CDC.ArchiveDeleteRowCount
(
  lnd_updatedate DATE,
  databasename STRING NOT NULL,
  tablename STRING NOT NULL,
  cdcflag INT64,
  archiveflag INT64,
  harddeletetableflag INT64,
  archivemasterlistflag INT64,
  lnd_updatetype STRING,
  row_count INT64,
  rowcountdate DATETIME,
  src_changedate DATETIME
)
;