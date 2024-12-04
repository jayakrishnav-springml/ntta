## Translation time: 2024-03-21T20:56:06.764423Z
## Translation job ID: e212c5d3-a7fa-4886-93b1-cb3be341e70a
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/EDW_RITE/Tables/dbo_CTE_VIOLATIONS_XREF.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_RITE.Cte_Violations_Xref
(
  month_id INT64,
  day_id INT64,
  lane_id INT64 NOT NULL,
  vehicle_class INT64 NOT NULL,
  vcly_id INT64 NOT NULL,
  license_plate_id INT64 NOT NULL,
  lane_viol_id NUMERIC(29) NOT NULL,
  violation_id INT64 NOT NULL,
  last_invoice_id INT64,
  vbi_invoice_id INT64 NOT NULL,
  viol_invoice_id INT64 NOT NULL,
  vbi_invoice_date DATE,
  vi_invoice_date DATETIME,
  vbi_status STRING,
  viol_inv_status STRING,
  violator_id NUMERIC(29) NOT NULL,
  fine_amount NUMERIC(31, 2) NOT NULL,
  delete_status INT64,
  vbb_ln_batch_id INT64 NOT NULL,
  date_excused DATETIME,
  excused_reason STRING,
  excused_by STRING,
  dps_inv_status STRING,
  ca_inv_status STRING,
  viol_status STRING NOT NULL,
  inv_toll_due NUMERIC(31, 2) NOT NULL,
  toll_due NUMERIC(31, 2),
  inv_fees_due NUMERIC(31, 2) NOT NULL,
  toll_paid NUMERIC(31, 2) NOT NULL,
  current_flag INT64 NOT NULL
)
;
