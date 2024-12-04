## Translation time: 2024-03-04T06:44:00.523569Z
## Translation job ID: a86d938d-fa65-424d-bf4e-0008985e1778
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_TBOS/Tables/Reporting_ExcusalDetailReport.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_TBOS.Reporting_ExcusalDetailReport
(
  snapshotmonthid INT64 NOT NULL,
  tptripid INT64 NOT NULL,
  customerid INT64,
  vehiclenumber STRING,
  lanename STRING,
  tripdate DATETIME,
  excuseddatetime DATETIME,
  tripstatusdate DATETIME,
  tollamount NUMERIC(31, 2),
  tollexcused NUMERIC(31, 2),
  adminfee1 NUMERIC(31, 2),
  adminfee1waived NUMERIC(31, 2),
  adminfee2 NUMERIC(31, 2),
  adminfee2waived NUMERIC(31, 2),
  reasoncode STRING,
  grouplevel STRING NOT NULL,
  excuseby STRING,
  lnd_updatedate DATETIME,
  src_changedate DATETIME
)
CLUSTER BY
tptripid
;