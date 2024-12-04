-- Translation time: 2024-06-04T08:04:57.852399Z
-- Translation job ID: d189ef38-1420-4658-96a7-29624b482bd7
-- Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_LG_VPS/Tables/VP_OWNER_AP_USERS.sql
-- Translated from: SqlServer
-- Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_LG_VPS.Vp_Owner_Ap_Users
(
  ap_user_id INT64 NOT NULL,
  display_name STRING NOT NULL,
  user_name STRING NOT NULL,
  access_string STRING,
  employee_number NUMERIC(29),
  working_pos_id INT64,
  date_created DATETIME NOT NULL,
  created_by STRING NOT NULL,
  date_modified DATETIME,
  modified_by STRING,
  password STRING,
  email_address STRING,
  restricted STRING NOT NULL,
  status STRING NOT NULL,
  last_login_date DATETIME,
  user_session_id STRING,
  last_update_type STRING NOT NULL,
  last_update_date DATETIME NOT NULL
)
cluster by ap_user_id
;
