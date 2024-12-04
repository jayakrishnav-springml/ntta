## Translation time: 2024-03-04T06:44:00.523569Z
## Translation job ID: a86d938d-fa65-424d-bf4e-0008985e1778
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_TBOS/Tables/Archive_TP_CustTxns.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_TBOS_ARCHIVE.TP_CustTxns
(
  archid INT64 NOT NULL,
  custtxnid INT64 NOT NULL,
  archivebatchid INT64 NOT NULL,
  archivedate DATETIME NOT NULL,
  lnd_updatedate DATETIME
)
;