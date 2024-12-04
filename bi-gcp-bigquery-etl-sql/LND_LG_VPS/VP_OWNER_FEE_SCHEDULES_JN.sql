-- Translation time: 2024-06-04T08:04:57.852399Z
-- Translation job ID: d189ef38-1420-4658-96a7-29624b482bd7
-- Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_LG_VPS/Tables/VP_OWNER_FEE_SCHEDULES_JN.sql
-- Translated from: SqlServer
-- Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_LG_VPS.Vp_Owner_Fee_Schedules_Jn
(
  jn_operation STRING NOT NULL,
  jn_oracle_user STRING NOT NULL,
  jn_datetime DATETIME NOT NULL,
  jn_notes STRING,
  jn_appln STRING,
  jn_session BIGNUMERIC(38),
  fee_id NUMERIC(29) NOT NULL,
  fee_type_code STRING,
  from_num_days INT64,
  to_num_days INT64,
  fee_amt NUMERIC(31, 2),
  date_created DATETIME,
  created_by STRING,
  date_modified DATETIME,
  modified_by STRING,
  last_update_date DATETIME,
  last_update_type STRING
)
;
