## Translation time: 2024-03-13T05:19:34.327071Z
## Translation job ID: 0a711804-adbe-4db7-8cda-d8808bd4ce52
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/NTTA_Missing_DDLs/EDW_TRIPS_dbo_Fact_PaymentPlan.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_TRIPS_APS.Fact_PaymentPlan
(
  paymentplanid INT64 NOT NULL,
  customerid INT64 NOT NULL,
  hvid INT64,
  vehicleid INT64 NOT NULL,
  mbsid INT64 NOT NULL,
  custtagid STRING NOT NULL,
  paymentplanstatusid INT64,
  agreementactivedayid INT64,
  hvstage STRING,
  quoteexpirydate DATETIME,
  quotefinalizeddate DATETIME,
  quotesigneddate DATETIME,
  defaulteddate DATETIME,
  statusdatetime DATETIME,
  downpaymentdate DATETIME,
  lastinstallmentduedate DATETIME,
  lastpaiddate DATE,
  nextduedate DATE,
  paidinfulldate DATETIME,
  previousdefaultscount INT64,
  totalnoofmonths INT64,
  noofinvoices INT64,
  nooftransactions INT64,
  mbsdue NUMERIC(31, 2),
  calculateddownpayment NUMERIC(31, 2),
  customdownpayment NUMERIC(31, 2),
  monthlypayment NUMERIC(31, 2),
  paidamount NUMERIC(31, 2),
  remainingamount NUMERIC(31, 2),
  lastpaidamount NUMERIC(31, 2),
  settlementamount NUMERIC(31, 2),
  tollamount NUMERIC(31, 2),
  feeamount NUMERIC(31, 2),
  edw_updatedate DATETIME NOT NULL
)
CLUSTER BY hvid
;