-- Translation time: 2024-06-04T08:03:02.538216Z
-- Translation job ID: 2ee163b6-d1ed-4585-9295-ffd9f05ba970
-- Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_LG_TS/Tables/TAG_OWNER_RETAIL_TRXN_DETAILS28aa3a05a6d1485c9539cb22f4015d4a.sql
-- Translated from: SqlServer
-- Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_LG_TS.Tag_Owner_Retail_Trxn_Details28aa3a05a6d1485c9539cb22f4015d4a
(
  rtd_id INT64,
  retail_trans_id INT64,
  trans_amt NUMERIC(31, 2),
  trans_date DATETIME,
  trans_status STRING,
  date_created DATETIME,
  created_by STRING,
  date_modified DATETIME,
  trans_type_id NUMERIC(29),
  agency_id STRING,
  tag_id STRING,
  modified_by STRING,
  credited_flag STRING,
  credit_src_code STRING,
  credit_src_id1 NUMERIC(29),
  credit_src_id2 INT64,
  link_id NUMERIC(29),
  reason_id FLOAT64,
  supervisor_ap_user_id FLOAT64,
  prc1 STRING,
  prc2 STRING,
  prc3 STRING,
  ol_pmt_det_id NUMERIC(29),
  last_update_type STRING,
  last_update_date DATETIME
)
cluster by retail_trans_id, rtd_id
;
