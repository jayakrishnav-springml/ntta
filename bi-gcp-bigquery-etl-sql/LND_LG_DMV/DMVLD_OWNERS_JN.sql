-- Translation time: 2024-05-22T12:36:41.830310Z
-- Translation job ID: d3568ee0-99d8-46a7-93e2-5d48994c87d3
-- Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_LG_DMV/Tables/DMVLD_OWNERS_JN.sql
-- Translated from: SqlServer
-- Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_LG_DMV.Dmvld_Owners_Jn
(
  jn_operation STRING NOT NULL,
  jn_oracle_user STRING NOT NULL,
  jn_datetime DATETIME NOT NULL,
  jn_notes STRING,
  jn_appln STRING,
  jn_session BIGNUMERIC(38),
  id NUMERIC(29) NOT NULL,
  owner_type STRING,
  full_name STRING,
  first_name STRING,
  middle_name STRING,
  last_name STRING,
  drec_id NUMERIC(29),
  created_by STRING,
  date_created DATETIME,
  modified_by STRING,
  date_modified DATETIME,
  first_name2 STRING,
  middle_name2 STRING,
  last_name2 STRING,
  last_update_date DATETIME,
  last_update_type STRING
)
;
