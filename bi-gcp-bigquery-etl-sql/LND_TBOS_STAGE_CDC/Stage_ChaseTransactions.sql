## Translation time: 2024-03-04T06:44:00.523569Z
## Translation job ID: a86d938d-fa65-424d-bf4e-0008985e1778
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_TBOS/Tables/Stage_ChaseTransactions.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_TBOS_STAGE_CDC.Finance_ChaseTransactions
(
  chasetransactionid INT64 NOT NULL,
  paymentid INT64,
  txnrefnum STRING,
  customerrefnum STRING,
  responsecode STRING,
  responsemessage STRING,
  tracenumber INT64,
  uid STRING,
  sourceid INT64,
  createddate DATETIME,
  updateddate DATETIME,
  cardexpiry STRING,
  cardkey STRING,
  name STRING,
  cardtype STRING,
  txndate DATETIME,
  amount NUMERIC(31, 2),
  cvvmatch STRING,
  avsmatch STRING,
  transactionstatus INT64,
  originaltxnrefnum STRING,
  error STRING,
  merchantid STRING,
  isaddingnewcard INT64 NOT NULL,
  mitreceivedtransactionid STRING,
  createduser STRING,
  updateduser STRING,
  lnd_updatedate DATETIME,
  lnd_updatetype STRING,
  src_changedate DATETIME
)
CLUSTER BY chasetransactionid
;