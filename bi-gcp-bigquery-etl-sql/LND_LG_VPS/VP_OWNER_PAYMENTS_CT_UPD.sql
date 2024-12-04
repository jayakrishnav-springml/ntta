-- Translation time: 2024-06-04T08:04:57.852399Z
-- Translation job ID: d189ef38-1420-4658-96a7-29624b482bd7
-- Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_LG_VPS/Tables/VP_OWNER_PAYMENTS_CT_UPD.sql
-- Translated from: SqlServer
-- Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_LG_VPS.Vp_Owner_Payments_Ct_Upd
(
  payment_txn_id INT64 NOT NULL,
  payment_date DATETIME NOT NULL,
  amount_due NUMERIC(33, 4) NOT NULL,
  amount_tendered NUMERIC(33, 4) NOT NULL,
  amount_returned NUMERIC(33, 4),
  amount_reversed NUMERIC(33, 4),
  amount_refunded NUMERIC(33, 4),
  delivery_code STRING NOT NULL,
  refund_requested STRING NOT NULL,
  receipt_requested STRING NOT NULL,
  is_change_returned STRING NOT NULL,
  rpt_generated STRING NOT NULL,
  rpt_generated_date DATETIME,
  shift_id INT64,
  violator_id NUMERIC(29),
  lic_plate_nbr STRING NOT NULL,
  lic_plate_state STRING NOT NULL,
  payment_status STRING NOT NULL,
  payment_source_code STRING NOT NULL,
  viol_pay_type STRING NOT NULL,
  online_txn_id INT64,
  ref_txn_id INT64 NOT NULL,
  comment_date DATETIME,
  old_payment_id FLOAT64,
  created_by STRING NOT NULL,
  date_created DATETIME NOT NULL,
  modified_by STRING,
  date_modified DATETIME,
  ca_bank_deposit_id INT64,
  ol_pmt_id NUMERIC(29),
  retail_trans_id NUMERIC(29),
  insert_datetime DATETIME NOT NULL
)
;
