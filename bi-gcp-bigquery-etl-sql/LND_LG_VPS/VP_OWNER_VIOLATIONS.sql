-- Translation time: 2024-06-04T08:04:57.852399Z
-- Translation job ID: d189ef38-1420-4658-96a7-29624b482bd7
-- Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_LG_VPS/Tables/VP_OWNER_VIOLATIONS.sql
-- Translated from: SqlServer
-- Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_LG_VPS.Vp_Owner_Violations
(
  violation_id BIGNUMERIC(48, 10) NOT NULL,
  lane_id NUMERIC(29) NOT NULL,
  viol_date DATETIME NOT NULL,
  viol_time DATETIME,
  viol_type STRING NOT NULL,
  toll_due NUMERIC(31, 2) NOT NULL,
  toll_paid NUMERIC(31, 2) NOT NULL,
  lic_plate_nbr STRING NOT NULL,
  lic_plate_state STRING NOT NULL,
  vehicle_class NUMERIC(29) NOT NULL,
  viol_status STRING NOT NULL,
  status_date DATETIME NOT NULL,
  vehicle_make STRING,
  vehicle_model STRING,
  vehicle_color STRING,
  vehicle_year INT64,
  vehicle_body STRING,
  occupant_descr STRING,
  no_pay_attempt STRING NOT NULL,
  window_up STRING NOT NULL,
  recorded_by STRING,
  recorder_emp_id INT64 NOT NULL,
  driver_lic_nbr STRING,
  driver_lic_state STRING,
  tolltag_acct_id INT64,
  tag_id STRING,
  agency_id STRING,
  created_by STRING NOT NULL,
  date_created DATETIME NOT NULL,
  modified_by STRING,
  date_modified DATETIME,
  excused_reason STRING,
  excused_by STRING,
  date_excused DATETIME,
  violator_id NUMERIC(29),
  review_status STRING,
  lane_viol_id NUMERIC(29),
  notification_date DATETIME,
  old_violator_id NUMERIC(29),
  transaction_id NUMERIC(29),
  disposition STRING,
  comment_date DATETIME,
  unpaid_toll_date DATETIME,
  host_transaction_id NUMERIC(29),
  vio_violation_id BIGNUMERIC(48, 10),
  icrs_date_created DATETIME,
  origin_type STRING,
  current_type STRING,
  transaction_file_detail_id NUMERIC(29),
  post_date DATETIME,
  last_update_type STRING,
  last_update_date DATETIME
)
cluster by violation_id
;
