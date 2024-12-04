## Translation time: 2024-03-21T20:56:06.764423Z
## Translation job ID: e212c5d3-a7fa-4886-93b1-cb3be341e70a
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/EDW_RITE/Tables/dbo_FACT_UNIFIED_VIOLATION_INVOICE_OLD.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_RITE.Fact_Unified_Violation_Invoice_Old
(
  day_id INT64,
  month_id INT64,
  violation_id INT64 NOT NULL,
  lane_viol_id NUMERIC(29) NOT NULL,
  viol_status STRING NOT NULL,
  lane_id INT64,
  vehicle_class INT64 NOT NULL,
  vcly_id INT64,
  license_plate_id INT64 NOT NULL,
  violator_id NUMERIC(29) NOT NULL,
  last_invoice_id INT64,
  vbi_invoice_id INT64 NOT NULL,
  vbi_invoice_date DATE,
  vbi_status STRING,
  viol_invoice_id INT64 NOT NULL,
  vi_invoice_date DATETIME,
  viol_inv_status STRING,
  invoice_stage_id INT64 NOT NULL,
  payment_date DATE NOT NULL,
  deposit_date DATE NOT NULL,
  pos_id INT64 NOT NULL,
  date_excused DATETIME,
  excused_reason STRING,
  excused_by STRING,
  inv_violations_cnt INT64,
  invoice_toll_due NUMERIC(31, 2),
  invoice_fees_due NUMERIC(31, 2),
  invoice_total_paid NUMERIC(31, 2) NOT NULL,
  toll_due NUMERIC(31, 2),
  fees_due NUMERIC(31, 2),
  payment_source_code STRING NOT NULL,
  split_amount NUMERIC(31, 2) NOT NULL,
  toll_paid NUMERIC(31, 2) NOT NULL,
  fees_paid NUMERIC(31, 2) NOT NULL,
  is_vtoll INT64 NOT NULL,
  current_flag INT64 NOT NULL,
  delete_status INT64
)
CLUSTER BY violation_id, vbi_invoice_id, viol_invoice_id;
