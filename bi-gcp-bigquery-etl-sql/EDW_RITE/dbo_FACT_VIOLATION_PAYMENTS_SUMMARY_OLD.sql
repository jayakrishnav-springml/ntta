## Translation time: 2024-03-21T20:56:06.764423Z
## Translation job ID: e212c5d3-a7fa-4886-93b1-cb3be341e70a
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/EDW_RITE/Tables/dbo_FACT_VIOLATION_PAYMENTS_SUMMARY_OLD.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_RITE.Fact_Violation_Payments_Summary_Old
(
  last_invoice_id INT64,
  violation_id INT64 NOT NULL,
  vbi_invoice_id INT64 NOT NULL,
  viol_invoice_id INT64 NOT NULL,
  violator_id NUMERIC(29) NOT NULL,
  is_vtoll INT64,
  nbr_of_pmts INT64,
  shift_id INT64,
  pos_id INT64,
  payment_id INT64,
  delivery_code STRING NOT NULL,
  payment_source_code STRING NOT NULL,
  payment_form STRING,
  payment_date DATE,
  deposit_date DATE,
  toll_due NUMERIC(31, 2),
  fees_due NUMERIC(31, 2),
  inv_toll_due NUMERIC(31, 2),
  inv_fees_due NUMERIC(31, 2),
  viol_amount NUMERIC(31, 2),
  vtoll_amount NUMERIC(31, 2),
  split_amount NUMERIC(31, 2),
  inv_amount NUMERIC(31, 2),
  toll_paid NUMERIC(31, 2),
  fees_paid NUMERIC(31, 2)
)
CLUSTER BY violation_id;
