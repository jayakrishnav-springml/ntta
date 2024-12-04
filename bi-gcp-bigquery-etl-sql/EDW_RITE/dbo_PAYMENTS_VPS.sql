## Translation time: 2024-03-21T20:56:06.764423Z
## Translation job ID: e212c5d3-a7fa-4886-93b1-cb3be341e70a
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/EDW_RITE/Tables/dbo_PAYMENTS_VPS.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_RITE.Payments_Vps
(
  violator_id NUMERIC(29),
  payment_txn_id INT64 NOT NULL,
  payment_date DATETIME NOT NULL,
  ref_txn_id INT64 NOT NULL,
  delivery_code STRING NOT NULL,
  shift_id INT64,
  payment_status STRING NOT NULL,
  retail_trans_id NUMERIC(29),
  payment_source_code STRING NOT NULL,
  viol_pay_type STRING NOT NULL,
  amount_due NUMERIC(33, 4) NOT NULL,
  amount_tendered NUMERIC(33, 4) NOT NULL,
  created_by STRING NOT NULL,
  insert_datetime DATETIME NOT NULL,
  last_update_date DATETIME NOT NULL
)
cluster by payment_txn_id
;
