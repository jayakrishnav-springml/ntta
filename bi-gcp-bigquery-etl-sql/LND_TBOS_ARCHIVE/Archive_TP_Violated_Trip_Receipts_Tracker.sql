## Translation time: 2024-03-04T06:44:00.523569Z
## Translation job ID: a86d938d-fa65-424d-bf4e-0008985e1778
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_TBOS/Tables/Archive_TP_Violated_Trip_Receipts_Tracker.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_TBOS_ARCHIVE.TP_Violated_Trip_Receipts_Tracker
(
  archid INT64 NOT NULL,
  tripreceiptid INT64 NOT NULL,
  archivebatchid INT64 NOT NULL,
  archivedate DATETIME NOT NULL,
  lnd_updatedate DATETIME
)
CLUSTER BY
tripreceiptid
;