## Translation time: 2024-03-04T06:41:57.683170Z
## Translation job ID: 00dc6676-2c12-444a-b02a-71c7788bdc89
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/EDW_TRIPS/Tables/dbo_Dim_PaymentPlan.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_TRIPS_APS.Dim_PaymentPlan
(
  paymentplanid INT64 NOT NULL,
  customerid INT64 NOT NULL,
  hvid INT64,
  mbsid INT64 NOT NULL,
  custtagid STRING NOT NULL,
  hvstage STRING,
  statuslookupcode STRING,
  statusdescription STRING,
  statusdatetime DATETIME,
  agreementactivedate DATETIME,
  lastinstallmentduedate DATETIME,
  lastpaiddate DATE,
  nextduedate DATE,
  defaulteddate DATETIME,
  paidinfulldate DATETIME,
  quoteexpirydate DATETIME,
  quotefinalizeddate DATETIME,
  quotesigneddate DATETIME,
  downpaymentdate DATETIME,
  previousdefaultscount INT64,
  totalnoofmonths INT64,
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