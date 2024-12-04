-- Translation time: 2024-06-04T08:03:02.538216Z
-- Translation job ID: 2ee163b6-d1ed-4585-9295-ffd9f05ba970
-- Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_LG_TS/Tables/TAG_OWNER_PAYMENTS_CT_UPD.sql
-- Translated from: SqlServer
-- Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_LG_TS.Tag_Owner_Payments_Ct_Upd
(
  retail_trans_id INT64,
  pmt_id INT64,
  pt_type_id INT64,
  name STRING,
  pmt_amount NUMERIC(31, 2),
  pmt_date DATETIME,
  pmt_status STRING,
  credit_source STRING,
  date_created DATETIME,
  created_by STRING,
  date_modified DATETIME,
  modified_by STRING,
  check_number NUMERIC(29),
  credited_flag STRING,
  zip STRING,
  session_data STRING,
  data2 STRING,
  address1 STRING,
  address2 STRING,
  supervisor_ap_user_id FLOAT64,
  pmt_rev_retail_trans_id FLOAT64,
  pmt_rev_pt_type_id FLOAT64,
  reversed_by STRING,
  insert_datetime DATETIME NOT NULL
)
;
