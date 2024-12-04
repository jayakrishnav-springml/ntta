## Translation time: 2024-03-21T20:56:06.764423Z
## Translation job ID: e212c5d3-a7fa-4886-93b1-cb3be341e70a
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/EDW_RITE/Tables/dbo_VIOLATIONS_STAGE.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_RITE.Violations_Stage
(
  violation_id NUMERIC(29),
  violator_id NUMERIC(29),
  lane_id NUMERIC(29),
  lic_plate_nbr STRING NOT NULL,
  lic_plate_state STRING NOT NULL,
  viol_status STRING NOT NULL,
  viol_date DATETIME NOT NULL,
  viol_time_id INT64,
  toll_due NUMERIC(31, 2) NOT NULL,
  toll_paid NUMERIC(31, 2) NOT NULL,
  transaction_file_detail_id NUMERIC(29),
  post_date DATE,
  post_time_id INT64,
  subscriber_unique_id NUMERIC(29),
  received_date DATE,
  received_time_id INT64,
  status_date DATE,
  date_created DATE,
  lane_viol_id NUMERIC(29),
  date_excused DATE,
  excused_reason STRING,
  excused_by STRING,
  vehicle_class NUMERIC(29) NOT NULL,
  viol_type STRING NOT NULL,
  last_update_type STRING,
  last_update_date DATETIME
)
;
