-- Translation time: 2024-06-04T08:04:57.852399Z
-- Translation job ID: d189ef38-1420-4658-96a7-29624b482bd7
-- Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_LG_VPS/Tables/FPL_OWNER_EMPLOYEES.sql
-- Translated from: SqlServer
-- Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_LG_VPS.Fpl_Owner_Employees
(
  empl_id NUMERIC(29) NOT NULL,
  employee_number NUMERIC(29) NOT NULL,
  last_name STRING NOT NULL,
  first_name STRING NOT NULL,
  middle_name STRING,
  user_name STRING,
  empl_id_supervised_by NUMERIC(29),
  pin STRING,
  ssn STRING,
  card_number INT64,
  card_issue_number INT64,
  hire_date DATETIME,
  terminate_date DATETIME,
  job_code STRING,
  created_by STRING NOT NULL,
  creation_date DATETIME NOT NULL,
  updated_date DATETIME NOT NULL,
  updated_by STRING NOT NULL,
  last_update_date DATETIME,
  last_update_type STRING
)
;
