## Translation time: 2024-03-21T20:56:06.764423Z
## Translation job ID: e212c5d3-a7fa-4886-93b1-cb3be341e70a
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/EDW_RITE/Tables/dbo_PAYMENTS_VPS_DETAIL.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_RITE.Payments_Vps_Detail
(
  day_id INT64,
  month_id INT64,
  payment_id INT64,
  last_invoice_id INT64,
  violation_id INT64,
  vbi_invoice_id INT64,
  viol_invoice_id INT64,
  vtoll INT64,
  payment_date DATETIME,
  deposit_date DATETIME,
  return_payment_date DATETIME,
  payment_form STRING,
  payment_txn_id INT64,
  payment_line_item_id INT64,
  violator_id NUMERIC(29),
  lic_plate_nbr STRING NOT NULL,
  lic_plate_state STRING NOT NULL,
  license_plate_id INT64,
  payment_status STRING NOT NULL,
  payment_source_code STRING NOT NULL,
  delivery_code STRING NOT NULL,
  shift_id INT64 NOT NULL,
  pos_id INT64 NOT NULL,
  paid_amount NUMERIC(31, 2),
  return_amount NUMERIC(31, 2),
  amount NUMERIC(31, 2),
  last_update_date DATETIME
)
cluster by payment_id
;
