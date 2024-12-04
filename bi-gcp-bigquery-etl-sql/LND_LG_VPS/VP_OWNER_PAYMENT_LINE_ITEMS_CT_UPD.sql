-- Translation time: 2024-06-04T08:04:57.852399Z
-- Translation job ID: d189ef38-1420-4658-96a7-29624b482bd7
-- Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_LG_VPS/Tables/VP_OWNER_PAYMENT_LINE_ITEMS_CT_UPD.sql
-- Translated from: SqlServer
-- Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_LG_VPS.Vp_Owner_Payment_Line_Items_Ct_Upd
(
  payment_line_item_id INT64,
  payment_txn_id INT64,
  payment_line_item_date DATETIME,
  pmt_txn_type STRING,
  payment_line_item_amount NUMERIC(31, 2),
  payment_form STRING,
  check_mo_date DATETIME,
  name_on_payment STRING,
  credit_card_type STRING,
  driver_lic_nbr STRING,
  driver_lic_state STRING,
  address STRING,
  city STRING,
  state STRING,
  zip_code STRING,
  email_address STRING,
  payment_status STRING,
  ref_line_item_id INT64,
  online_evs_trans_id STRING,
  date_created DATETIME,
  created_by STRING,
  date_modified DATETIME,
  modified_by STRING,
  insert_datetime DATETIME NOT NULL
)
;
