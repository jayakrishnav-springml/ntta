## Translation time: 2024-03-21T20:56:06.764423Z
## Translation job ID: e212c5d3-a7fa-4886-93b1-cb3be341e70a
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/EDW_RITE/Tables/dbo_FACT_INVOICE_ANALYSIS_DETAIL_FINAL.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_RITE.Fact_Invoice_Analysis_Detail_Final
(
  violator_id NUMERIC(29) NOT NULL,
  partition_date DATE NOT NULL,
  violation_id NUMERIC(29) NOT NULL,
  current_invoice_level_flag INT64 NOT NULL,
  vbi_invoice_id INT64 NOT NULL,
  vb_inv_date DATE NOT NULL,
  vb_inv_date_excused DATE NOT NULL,
  viol_invoice_id INT64,
  converted_date DATE NOT NULL,
  viol_inv_date_excused DATE NOT NULL,
  paid_date DATE,
  pos_id INT64,
  viol_date DATETIME NOT NULL,
  viol_time_id INT64 NOT NULL,
  viol_post_date DATE NOT NULL,
  viol_paid_date DATE NOT NULL,
  viol_status_date DATE NOT NULL,
  viol_date_excused DATE NOT NULL,
  violation_or_zipcash STRING NOT NULL,
  lane_id NUMERIC(29) NOT NULL,
  source_code STRING NOT NULL,
  inv_dtl_viol_status STRING NOT NULL,
  viol_status STRING NOT NULL,
  last_violator_id NUMERIC(29) NOT NULL,
  transaction_id NUMERIC(29) NOT NULL,
  disposition STRING NOT NULL,
  vps_host_posted_revenue NUMERIC(31, 2) NOT NULL,
  vps_host_posted_date DATE NOT NULL,
  viol_type STRING NOT NULL,
  invoice_amt NUMERIC(33, 4),
  toll_due NUMERIC(33, 4),
  vehicle_class NUMERIC(29) NOT NULL,
  zi_late_fees NUMERIC(33, 4),
  vi_late_fees NUMERIC(33, 4),
  admin_fee NUMERIC(33, 4),
  admin_fee2 NUMERIC(33, 4),
  amt_paid NUMERIC(33, 4),
  amt_paid_disc NUMERIC(37, 8),
  amt_paid_adj NUMERIC(37, 8),
  viol_amt_paid NUMERIC(33, 4),
  viol_left_on_inv_flag INT64 NOT NULL,
  insert_date DATETIME NOT NULL
)
;
