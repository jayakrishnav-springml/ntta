-- Translation time: 2024-06-04T08:04:57.852399Z
-- Translation job ID: d189ef38-1420-4658-96a7-29624b482bd7
-- Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_LG_VPS/Tables/VP_OWNER_VIOLATOR_ADDRESS.sql
-- Translated from: SqlServer
-- Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_LG_VPS.Vp_Owner_Violator_Address
(
  violator_id NUMERIC(29),
  violator_addr_seq INT64,
  co_alt_fname STRING,
  co_alt_lname STRING,
  address1 STRING,
  address2 STRING,
  city STRING,
  state STRING,
  zip_code STRING,
  plus4 STRING,
  addr_source_date DATETIME,
  comment_date DATETIME,
  created_by STRING,
  date_created DATETIME,
  modified_by STRING,
  addr_status STRING,
  addr_source STRING,
  date_modified DATETIME,
  is_sts_upd_by_sys STRING,
  bad_to_good_address_update_dt DATETIME,
  last_update_type STRING,
  last_update_date DATETIME
)
cluster by violator_id
;
