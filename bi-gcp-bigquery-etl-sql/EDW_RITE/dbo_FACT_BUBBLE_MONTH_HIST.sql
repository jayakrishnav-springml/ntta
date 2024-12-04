## Translation time: 2024-03-21T20:56:06.764423Z
## Translation job ID: e212c5d3-a7fa-4886-93b1-cb3be341e70a
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/EDW_RITE/Tables/dbo_FACT_BUBBLE_MONTH_HIST.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_RITE.Fact_Bubble_Month_Hist
(
  facility_id NUMERIC(29) NOT NULL,
  bubl_cat_id INT64 NOT NULL,
  txn_month DATE,
  txn_monthid INT64,
  asof_month_id INT64,
  partition_date DATE,
  txn_cnt FLOAT64,
  txn_amount NUMERIC(33, 4),
  days_to_invoice_paid INT64,
  days_to_invoice INT64,
  days_to_invoice_vtoll INT64,
  days_to_vtoll INT64,
  days_to_pmt INT64,
  bubl_source_desc STRING NOT NULL,
  insert_datetime DATETIME,
  effective_datetime DATETIME,
  expired_datetime DATETIME,
  is_current INT64
)
;
