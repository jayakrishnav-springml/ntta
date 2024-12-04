## Translation time: 2024-03-21T20:56:06.764423Z
## Translation job ID: e212c5d3-a7fa-4886-93b1-cb3be341e70a
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/EDW_RITE/Tables/dbo_TEMP_OPENED_CLOSED_TAGS.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_RITE.Temp_Opened_Closed_Tags
(
  month_id INT64,
  acct_id NUMERIC(29),
  acct_tag_seq INT64,
  tag_history_seq INT64,
  tag_id STRING,
  acct_tag_status STRING NOT NULL,
  assigned_date DATETIME,
  status_rn INT64,
  change_num INT64,
  change_num_seq INT64
)
;
