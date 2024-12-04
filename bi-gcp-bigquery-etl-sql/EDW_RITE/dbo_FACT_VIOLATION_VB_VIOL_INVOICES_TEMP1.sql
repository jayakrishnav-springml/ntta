## Translation time: 2024-03-21T20:56:06.764423Z
## Translation job ID: e212c5d3-a7fa-4886-93b1-cb3be341e70a
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/EDW_RITE/Tables/dbo_FACT_VIOLATION_VB_VIOL_INVOICES_TEMP1.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_RITE.Fact_Violation_Vb_Viol_Invoices_Temp1
(
  day_id INT64,
  lane_id NUMERIC(29) NOT NULL,
  vehicle_class NUMERIC(29) NOT NULL,
  vcly_id NUMERIC(29) NOT NULL,
  license_plate_id INT64,
  lane_viol_id NUMERIC(29) NOT NULL,
  violation_id NUMERIC(29) NOT NULL,
  vbi_invoice_id NUMERIC(29),
  viol_invoice_id NUMERIC(29),
  violator_id NUMERIC(29),
  vbi_invoice_date DATETIME,
  vi_invoice_date DATE,
  viol_status STRING NOT NULL,
  vbi_status STRING,
  viol_inv_status STRING,
  date_excused DATETIME,
  excused_reason STRING,
  excused_by STRING,
  inv_toll_due NUMERIC(31, 2),
  toll_due NUMERIC(31, 2),
  inv_fees_due NUMERIC(31, 2),
  toll_paid NUMERIC(31, 2) NOT NULL,
  invoice_stage_id INT64 NOT NULL,
  delete_status INT64 NOT NULL
)
CLUSTER BY lane_id,violation_id;
