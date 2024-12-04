## Translation time: 2024-03-04T06:44:00.523569Z
## Translation job ID: a86d938d-fa65-424d-bf4e-0008985e1778
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_TBOS/Tables/Finance_PaymentTxns.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_TBOS.Finance_PaymentTxns
(
  paymentid INT64 NOT NULL,
  paymentdate DATETIME NOT NULL,
  voucherno STRING,
  subsystem STRING,
  paymentmodeid INT64 NOT NULL,
  intiatedby STRING,
  activitytype STRING,
  statementnote STRING,
  txnamount NUMERIC(31, 2) NOT NULL,
  paymentstatusid INT64 NOT NULL,
  refpaymentid INT64,
  reftype STRING,
  sourcepkid INT64,
  accountstatusid INT64 NOT NULL,
  approvedby STRING,
  channelid INT64,
  locationid INT64,
  sourceofentry INT64,
  reasontext STRING,
  icnid INT64,
  isvirtualcheck INT64,
  pmttxntype STRING,
  sourcepmtid INT64,
  createddate DATETIME NOT NULL,
  createduser STRING,
  updateddate DATETIME NOT NULL,
  updateduser STRING,
  lnd_updatedate DATETIME,
  lnd_updatetype STRING,
  src_changedate DATETIME
)
CLUSTER BY
paymentid
;