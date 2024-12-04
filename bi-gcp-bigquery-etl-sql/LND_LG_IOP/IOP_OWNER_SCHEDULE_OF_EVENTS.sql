-- Translation time: 2024-06-04T08:01:15.437249Z
-- Translation job ID: a14a1a7f-7d63-47c9-8296-0b7483d5c271
-- Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_LG_IOP/Tables/IOP_OWNER_SCHEDULE_OF_EVENTS.sql
-- Translated from: SqlServer
-- Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_LG_IOP.Iop_Owner_Schedule_Of_Events
(
  schedule_id FLOAT64 NOT NULL,
  event_id FLOAT64 NOT NULL,
  schedule_timing_id FLOAT64 NOT NULL,
  execution_days STRING,
  frequency_start_time STRING NOT NULL,
  frequency_end_time STRING,
  increment_type_id FLOAT64 NOT NULL,
  frequency_increment FLOAT64,
  duration_start_date DATETIME,
  duration_end_date DATETIME,
  execute_on_parent_completion STRING,
  last_run_date DATETIME,
  last_completion_date DATETIME,
  last_param_id FLOAT64,
  run_count FLOAT64,
  date_created DATETIME NOT NULL,
  created_by STRING NOT NULL,
  date_modified DATETIME NOT NULL,
  modified_by STRING NOT NULL,
  schedule_limit INT64,
  last_update_date DATETIME,
  last_update_type STRING
)
;
