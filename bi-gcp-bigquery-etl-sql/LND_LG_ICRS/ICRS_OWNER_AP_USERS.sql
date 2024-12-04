-- Translation time: 2024-06-04T07:59:17.388387Z
-- Translation job ID: 5118bff3-1545-4bd3-96b6-65be13aded87
-- Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_LG_ICRS/Tables/ICRS_OWNER_AP_USERS.sql
-- Translated from: SqlServer
-- Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_LG_ICRS.Icrs_Owner_Ap_Users        
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
  failed_login_ctr FLOAT64,
  last_failed_login_date DATETIME,
  password_change_date DATETIME,
  last_login_date DATETIME,
  last_update_type STRING NOT NULL,
  last_update_date DATETIME NOT NULL
)
CLUSTER BY ap_user_id
;
