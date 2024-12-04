## Translation time: 2024-03-04T06:44:00.523569Z
## Translation job ID: a86d938d-fa65-424d-bf4e-0008985e1778
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_TBOS/Tables/Stage_PaymentPlans.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_TBOS_STAGE_FULL.TER_PaymentPlans
(
  paymentplanid INT64 NOT NULL,
  remedystage STRING,
  custtagid STRING,
  agreementlocation STRING,
  statuslookupcode STRING,
  statusdatetime DATETIME,
  totalamountpayable NUMERIC(31, 2),
  calculateddownpayment NUMERIC(31, 2),
  customdownpayment NUMERIC(31, 2),
  monthlypayment NUMERIC(31, 2),
  totalnoofmonths INT64,
  startdate DATETIME,
  enddate DATETIME,
  totalreceived NUMERIC(31, 2),
  balancedue NUMERIC(31, 2),
  lastpaiddate DATE,
  nextduedate DATE,
  lastpaidamount NUMERIC(31, 2),
  defaulteddate DATETIME,
  defaultscount INT64,
  paidinfulldate DATETIME,
  quoteexpirydate DATETIME,
  totalsettlementamount NUMERIC(31, 2),
  quotefinalizeddate DATETIME,
  quotesigneddate DATETIME,
  downpaymentdate DATETIME,
  downpaymentapprovedby STRING,
  cashpaymentapprovedby STRING,
  tollamount NUMERIC(31, 2),
  feeamount NUMERIC(31, 2),
  citationnumber STRING,
  filepathconfigurationid INT64,
  createddate DATETIME,
  createduser STRING,
  updateddate DATETIME,
  updateduser STRING,
  lnd_updatedate DATETIME,
  lnd_updatetype STRING,
  src_changedate DATETIME
)
cluster by paymentplanid
;