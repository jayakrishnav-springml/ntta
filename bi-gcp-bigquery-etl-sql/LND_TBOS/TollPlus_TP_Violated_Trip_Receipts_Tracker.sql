## Translation time: 2024-03-04T06:44:00.523569Z
## Translation job ID: a86d938d-fa65-424d-bf4e-0008985e1778
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_TBOS/Tables/TollPlus_TP_Violated_Trip_Receipts_Tracker.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_TBOS.TollPlus_TP_Violated_Trip_Receipts_Tracker
(
  tripreceiptid INT64 NOT NULL,
  citationid INT64,
  violatorid INT64,
  linkid INT64,
  amountreceived NUMERIC(31, 2),
  txndate DATETIME,
  linksourcename STRING,
  tripchargeid INT64,
  invoiceid INT64,
  overpaymentid INT64,
  createddate DATETIME NOT NULL,
  createduser STRING,
  updateddate DATETIME NOT NULL,
  updateduser STRING,
  lnd_updatedate DATETIME,
  lnd_updatetype STRING,
  src_changedate DATETIME
)
cluster by tripreceiptid
;