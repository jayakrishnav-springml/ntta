## Translation time: 2024-03-21T20:56:06.764423Z
## Translation job ID: e212c5d3-a7fa-4886-93b1-cb3be341e70a
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/EDW_RITE/Tables/dbo_FACT_INVOICE_DETAIL_MISSING_VPS_HOST_TRANS.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_RITE.Fact_Invoice_Detail_Missing_Vps_Host_Trans
(
  violator_id NUMERIC(29),
  partition_date DATE,
  violation_id NUMERIC(29),
  current_invoice_level_flag INT64 NOT NULL,
  vbi_invoice_id INT64 NOT NULL,
  vb_inv_date STRING NOT NULL,
  vb_inv_date_excused STRING NOT NULL,
  viol_invoice_id INT64 NOT NULL,
  converted_date STRING NOT NULL,
  viol_inv_date_excused STRING NOT NULL,
  viol_date DATE,
  viol_time_id INT64 NOT NULL,
  viol_post_date STRING NOT NULL,
  viol_paid_date STRING NOT NULL,
  viol_status_date STRING NOT NULL,
  viol_date_excused STRING NOT NULL,
  violation_or_zipcash STRING,
  lane_id INT64 NOT NULL,
  source_code STRING NOT NULL,
  inv_dtl_viol_status STRING NOT NULL,
  viol_status STRING NOT NULL,
  last_violator_id NUMERIC(29),
  transaction_id NUMERIC(29) NOT NULL,
  disposition STRING NOT NULL,
  vps_host_posted_revenue NUMERIC(31, 2) NOT NULL,
  vps_host_posted_date DATE NOT NULL,
  viol_type STRING NOT NULL,
  toll_due NUMERIC(31, 2) NOT NULL,
  amt_paid NUMERIC(31, 2) NOT NULL,
  amt_paid_adj NUMERIC(31, 2) NOT NULL,
  amt_paid_disc INT64 NOT NULL,
  vehicle_class STRING NOT NULL,
  viol_left_on_inv_flag INT64 NOT NULL,
  insert_date DATETIME NOT NULL
)
;
