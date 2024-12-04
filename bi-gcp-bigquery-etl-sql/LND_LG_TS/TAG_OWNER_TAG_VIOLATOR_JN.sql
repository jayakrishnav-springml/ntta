-- Translation time: 2024-06-04T08:03:02.538216Z
-- Translation job ID: 2ee163b6-d1ed-4585-9295-ffd9f05ba970
-- Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_LG_TS/Tables/TAG_OWNER_TAG_VIOLATOR_JN.sql
-- Translated from: SqlServer
-- Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_LG_TS.Tag_Owner_Tag_Violator_Jn
(
  jn_operation STRING NOT NULL,
  jn_oracle_user STRING NOT NULL,
  jn_datetime DATETIME NOT NULL,
  jn_notes STRING,
  jn_appln STRING,
  jn_session BIGNUMERIC(38),
  tv_id NUMERIC(29) NOT NULL,
  acct_id NUMERIC(29),
  acct_tag_seq INT64,
  lic_plate STRING,
  lic_state STRING,
  violator_id NUMERIC(29),
  tv_start_date DATETIME,
  tv_end_date DATETIME,
  is_active STRING,
  date_created DATETIME,
  created_by STRING,
  date_modified DATETIME,
  modified_by STRING,
  last_update_date DATETIME,
  last_update_type STRING
)
;
