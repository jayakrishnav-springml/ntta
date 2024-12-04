-- Translation time: 2024-06-04T08:03:02.538216Z
-- Translation job ID: 2ee163b6-d1ed-4585-9295-ffd9f05ba970
-- Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_LG_TS/Tables/TAG_OWNER_OLC_PAYMENTS.sql
-- Translated from: SqlServer
-- Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_LG_TS.Tag_Owner_Olc_Payments
(
  ol_pmt_id NUMERIC(29) NOT NULL,
  pos_id INT64,
  ap_user_id INT64,
  pt_type_id INT64,
  driver_lic_state STRING,
  driver_lic_nbr STRING,
  pmt_amount NUMERIC(31, 2) NOT NULL,
  pmt_date DATETIME NOT NULL,
  posted_date DATETIME,
  pmt_status STRING,
  card_code STRING,
  card_number STRING,
  card_expires DATETIME,
  request_str STRING,
  return_str STRING,
  confirmation_code STRING,
  bank_acct_type STRING,
  bank_acct_number STRING,
  routing_nbr STRING,
  name_on_pmt STRING NOT NULL,
  address1 STRING,
  address2 STRING,
  city STRING,
  state STRING,
  zip_code STRING,
  plus4 STRING,
  email_address STRING,
  retail_trans_id INT64,
  session_data STRING,
  data2 STRING,
  error_code STRING,
  error_msg STRING,
  date_created DATETIME NOT NULL,
  created_by STRING,
  date_modified DATETIME,
  modified_by STRING,
  pmt_rev_id INT64,
  last_update_date DATETIME,
  last_update_type STRING
)
;
