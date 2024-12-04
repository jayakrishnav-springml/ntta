## Translation time: 2024-03-04T06:44:00.523569Z
## Translation job ID: a86d938d-fa65-424d-bf4e-0008985e1778
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_TBOS/Tables/Stage_MbsInvoices.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_TBOS_STAGE_FULL.TollPlus_MbsInvoices
(
  mbsinvoicesid INT64 NOT NULL,
  mbsid INT64 NOT NULL,
  invoiceid INT64 NOT NULL,
  agestageid INT64 NOT NULL,
  invoicenumber STRING,
  invaddedreasonid INT64,
  createddate DATETIME,
  createduser STRING,
  updateddate DATETIME,
  updateduser STRING,
  lnd_updatedate DATETIME,
  lnd_updatetype STRING,
  src_changedate DATETIME
)
cluster by mbsinvoicesid
;