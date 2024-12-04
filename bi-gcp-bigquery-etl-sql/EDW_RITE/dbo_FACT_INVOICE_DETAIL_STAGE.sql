## Translation time: 2024-03-21T20:56:06.764423Z
## Translation job ID: e212c5d3-a7fa-4886-93b1-cb3be341e70a
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/EDW_RITE/Tables/dbo_FACT_INVOICE_DETAIL_STAGE.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_RITE.Fact_Invoice_Detail_Stage
(
  invoice_category_id INT64 NOT NULL,
  violator_id INT64,
  vbi_invoice_id INT64,
  vb_inv_date DATETIME NOT NULL,
  vb_inv_date_excused DATE NOT NULL,
  viol_invoice_id INT64,
  converted_date DATE,
  viol_inv_date_excused DATE NOT NULL,
  amt_paid NUMERIC(33, 4),
  viol_amt_paid NUMERIC(33, 4),
  vps_host_posted_rev NUMERIC(31, 2) NOT NULL,
  violation_id INT64 NOT NULL,
  viol_time_id INT64,
  viol_date DATETIME NOT NULL,
  lane_id NUMERIC(29),
  toll_due_on_viol NUMERIC(31, 2) NOT NULL,
  toll_due_on_inv NUMERIC(33, 4),
  vehicle_class NUMERIC(29) NOT NULL,
  source_code STRING NOT NULL,
  inv_dtl_viol_status STRING,
  last_viol_status STRING NOT NULL,
  last_violator_id NUMERIC(29),
  transaction_id NUMERIC(29),
  disposition STRING NOT NULL,
  viol_type STRING NOT NULL,
  viol_status_date DATE NOT NULL,
  viol_post_date DATE NOT NULL,
  viol_date_excused DATE NOT NULL,
  violation_or_zipcash STRING NOT NULL,
  viol_paid_date DATE,
  vps_host_posted_revenue NUMERIC(31, 2) NOT NULL,
  vps_host_posted_date DATE NOT NULL,
  viol_left_on_inv_flag INT64 NOT NULL
)
cluster by violation_id
;
