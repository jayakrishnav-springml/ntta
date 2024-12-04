-- Translation time: 2024-06-04T08:04:57.852399Z
-- Translation job ID: d189ef38-1420-4658-96a7-29624b482bd7
-- Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_LG_VPS/Tables/VP_OWNER_CA_COMPANIES_JN_TRUNCATE.sql
-- Translated from: SqlServer
-- Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_LG_VPS.Vp_Owner_Ca_Companies_Jn_Truncate
(
  jn_operation STRING NOT NULL,
  jn_oracle_user STRING NOT NULL,
  jn_datetime DATETIME NOT NULL,
  jn_notes STRING,
  jn_appln STRING,
  jn_session BIGNUMERIC(38),
  ca_company_id INT64 NOT NULL,
  ca_company_name STRING NOT NULL,
  ca_company_descr STRING,
  ca_abbrev STRING NOT NULL,
  new_enabled STRING NOT NULL,
  pay_enabled STRING NOT NULL,
  undo_enabled STRING NOT NULL,
  min_amt_due NUMERIC(31, 2),
  max_amt_due NUMERIC(31, 2),
  max_new_accts NUMERIC(29) NOT NULL,
  new_acct_priority INT64 NOT NULL,
  display_name STRING,
  ca_phone_number STRING,
  new_acct_percentage BIGNUMERIC(48, 10),
  is_active STRING,
  date_created DATETIME,
  created_by STRING,
  date_modified DATETIME,
  modified_by STRING,
  applied_rule STRING,
  last_update_date DATETIME,
  last_update_type STRING
)
;
