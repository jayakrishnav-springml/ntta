## Translation time: 2024-03-21T20:56:06.764423Z
## Translation job ID: e212c5d3-a7fa-4886-93b1-cb3be341e70a
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/EDW_RITE/Tables/dbo_FACT_VPS_EXCUSALS.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_RITE.Fact_Vps_Excusals
(
  status_day_id INT64,
  transaction_type STRING NOT NULL,
  viol_date DATETIME,
  invoice_date DATETIME,
  e NUMERIC(29),
  violation_id FLOAT64,
  lane_viol_id NUMERIC(29),
  lane_name STRING,
  lic_plate_info STRING,
  excused_by STRING,
  excused_by_name STRING,
  excused_reas_descr STRING,
  invoice_amount NUMERIC(33, 4) NOT NULL,
  toll_amount NUMERIC(33, 4) NOT NULL,
  admin_fee_amount NUMERIC(33, 4) NOT NULL,
  excused_toll_amount NUMERIC(33, 4) NOT NULL,
  excused_admin_fee_amount NUMERIC(33, 4) NOT NULL,
  excused_late_fee_amount NUMERIC(33, 4) NOT NULL,
  paid_invoice_fee_amount NUMERIC(33, 4) NOT NULL,
  paid_amount NUMERIC(33, 4) NOT NULL,
  payment_form STRING,
  payment_source_code STRING,
  violator_id NUMERIC(29),
  transaction_source STRING,
  violator_type STRING,
  vtoll_type STRING,
  payment_txn_id INT64,
  source_code STRING,
  writeoff_flag STRING,
  lane_id NUMERIC(29),
  excused_inv_admin_fee2_amount NUMERIC(33, 4),
  last_update_type STRING NOT NULL,
  last_update_date DATETIME NOT NULL
)
CLUSTER BY status_day_id;
