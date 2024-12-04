## Translation time: 2024-03-21T20:56:06.764423Z
## Translation job ID: e212c5d3-a7fa-4886-93b1-cb3be341e70a
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/EDW_RITE/Tables/dbo_ACCOUNT_TAG_HISTORY.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_RITE.Account_Tag_History
(
  acct_id NUMERIC(29),
  acct_tag_seq INT64,
  tag_history_seq INT64,
  tag_id STRING,
  acct_tag_status STRING,
  assigned_date DATETIME,
  expired_date DATETIME,
  vehicle_id INT64 NOT NULL,
  vehicle_color_id INT64 NOT NULL,
  vehicle_class_code INT64 NOT NULL,
  license_plate_id INT64 NOT NULL,
  date_created DATETIME,
  insert_date DATETIME,
  last_update_date DATETIME
)
;
