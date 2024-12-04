-- Translation time: 2024-06-04T08:04:57.852399Z
-- Translation job ID: d189ef38-1420-4658-96a7-29624b482bd7
-- Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_LG_VPS/Tables/VP_OWNER_FA_AGENCIES.sql
-- Translated from: SqlServer
-- Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_LG_VPS.Vp_Owner_Fa_Agencies
(
  agency_id NUMERIC(29) NOT NULL,
  agency_type STRING NOT NULL,
  name STRING NOT NULL,
  phone STRING,
  address STRING,
  invoiceable STRING NOT NULL,
  abbrev STRING NOT NULL,
  date_created DATETIME NOT NULL,
  date_modified DATETIME NOT NULL,
  modified_by STRING NOT NULL,
  created_by STRING NOT NULL,
  next_variance_date DATETIME,
  max_variance_transactions NUMERIC(29),
  variance_record_window INT64,
  variance_file_schedule INT64,
  is_active STRING,
  max_variance_dollars NUMERIC(31, 2),
  max_chg_retry_days INT64,
  default_violator_type STRING,
  default_viol_status STRING,
  contact_fname STRING,
  contact_lname STRING,
  contact_address1 STRING,
  contact_address2 STRING,
  contact_city STRING,
  contact_state STRING,
  contact_zip_code STRING,
  contact_plus4 STRING,
  contact_email_addr STRING,
  include_plates_in_lvl STRING NOT NULL,
  variance_email_wait INT64 NOT NULL,
  last_update_date DATETIME,
  last_update_type STRING
)
;
