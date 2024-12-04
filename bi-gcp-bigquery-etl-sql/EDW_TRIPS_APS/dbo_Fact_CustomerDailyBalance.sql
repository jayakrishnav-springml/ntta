## Translation time: 2024-03-04T06:41:57.683170Z
## Translation job ID: 00dc6676-2c12-444a-b02a-71c7788bdc89
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/EDW_TRIPS/Tables/dbo_Fact_CustomerDailyBalance.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_TRIPS_APS.Fact_CustomerDailyBalance
(
  customerid INT64 NOT NULL,
  balancestartdate DATE,
  balanceenddate DATE,
  tolltxncount INT64 NOT NULL,
  tollamount NUMERIC(31, 2) NOT NULL,
  creditamount NUMERIC(31, 2) NOT NULL,
  debitamount NUMERIC(31, 2) NOT NULL,
  credittxncount INT64 NOT NULL,
  debittxncount INT64 NOT NULL,
  beginningbalanceamount NUMERIC(31, 2) NOT NULL,
  endingbalanceamount NUMERIC(31, 2) NOT NULL,
  calcendingbalanceamount NUMERIC(31, 2) NOT NULL,
  balancediffamount NUMERIC(31, 2) NOT NULL,
  beginningcusttxnid INT64,
  endingcusttxnid INT64,
  edw_updatedate DATETIME
)
PARTITION BY
  DATE_TRUNC(balancestartdate, MONTH)
  OPTIONS ( require_partition_filter = FALSE);