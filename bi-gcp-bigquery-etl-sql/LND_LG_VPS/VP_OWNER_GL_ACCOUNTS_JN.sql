-- Translation time: 2024-06-04T08:04:57.852399Z
-- Translation job ID: d189ef38-1420-4658-96a7-29624b482bd7
-- Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_LG_VPS/Tables/VP_OWNER_GL_ACCOUNTS_JN.sql
-- Translated from: SqlServer
-- Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_LG_VPS.Vp_Owner_Gl_Accounts_Jn
(
  jn_operation STRING NOT NULL,
  jn_oracle_user STRING NOT NULL,
  jn_datetime DATETIME NOT NULL,
  jn_notes STRING,
  jn_appln STRING,
  jn_session BIGNUMERIC(38),
  gl_acct_id INT64 NOT NULL,
  gl_acct_nbr STRING,
  acct_short_desc STRING,
  acct_long_desc STRING,
  attribute_1 STRING,
  attribute_2 STRING,
  attribute_3 STRING,
  attribute_4 STRING,
  attribute_5 STRING,
  attribute_6 STRING,
  attribute_7 STRING,
  attribute_8 STRING,
  attribute_9 STRING,
  attribute_10 STRING,
  attribute_11 STRING,
  attribute_12 STRING,
  attribute_13 STRING,
  attribute_14 STRING,
  attribute_15 STRING,
  attribute_16 STRING,
  created_by STRING,
  date_created DATETIME,
  modified_by STRING,
  date_modified DATETIME,
  last_update_date DATETIME,
  last_update_type STRING
)
;
