--Translated manually via BQ Interactive tool

CREATE TABLE IF NOT EXISTS LND_LG_IOP.Iop_Owner_Ap_Users
(
  ap_user_id INT64 NOT NULL,
  display_name STRING NOT NULL,
  user_name STRING NOT NULL,
  employee_number NUMERIC(29),
  password STRING,
  created_by STRING NOT NULL,
  date_created DATETIME NOT NULL,
  modified_by STRING,
  date_modified DATETIME,
  email_address STRING,
  restricted STRING NOT NULL,
  working_pos_id INT64,
  status STRING NOT NULL,
  last_login_timestamp DATETIME,
  user_session_id STRING,
  last_update_type STRING DEFAULT 'I' NOT NULL,
  last_update_date DATETIME NOT NULL
)
;
