## Translation time: 2024-03-04T06:44:00.523569Z
## Translation job ID: a86d938d-fa65-424d-bf4e-0008985e1778
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_TBOS/Tables/TollPlus_Invoice_Charges_Tracker.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_TBOS.TollPlus_Invoice_Charges_Tracker
(
  invoicechargeid INT64 NOT NULL,
  invoiceid INT64,
  invbatchid STRING,
  amount NUMERIC(31, 2),
  feecode STRING,
  paymentstatusid INT64,
  outstandingamount NUMERIC(31, 2),
  iswriteoff INT64,
  icnid INT64,
  writeoffdate DATETIME,
  writeoffamount NUMERIC(31, 2),
  createddate DATETIME NOT NULL,
  createduser STRING,
  updateddate DATETIME NOT NULL,
  updateduser STRING,
  lnd_updatedate DATETIME,
  lnd_updatetype STRING,
  src_changedate DATETIME
)
CLUSTER BY  InvoiceChargeID
;