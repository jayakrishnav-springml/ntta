-- Translation time: 2024-06-04T08:04:57.852399Z
-- Translation job ID: d189ef38-1420-4658-96a7-29624b482bd7
-- Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_LG_VPS/Tables/VP_OWNER_FA_AGENCIES_JN.sql
-- Translated from: SqlServer
-- Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_LG_VPS.Vp_Owner_Fa_Agencies_Jn
(
  jn_operation STRING NOT NULL,
  jn_oracle_user STRING NOT NULL,
  jn_datetime DATETIME NOT NULL,
  jn_notes STRING,
  jn_appln STRING,
  jn_session BIGNUMERIC(38),
  agency_id NUMERIC(29) NOT NULL,
  agency_type STRING,
  name STRING,
  abbrev STRING,
  is_active STRING,
  phone STRING,
  address STRING,
  invoiceable STRING,
  next_variance_date DATETIME,
  variance_record_window INT64,
  variance_file_schedule INT64,
  max_variance_transactions NUMERIC(29),
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
  date_created DATETIME,
  created_by STRING,
  date_modified DATETIME,
  modified_by STRING,
  last_update_date DATETIME,
  last_update_type STRING
)
;
