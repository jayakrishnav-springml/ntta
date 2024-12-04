## Translation time: 2024-03-21T20:56:06.764423Z
## Translation job ID: e212c5d3-a7fa-4886-93b1-cb3be341e70a
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/EDW_RITE/Tables/dbo_TEMP_MONTH_END_TAGS.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_RITE.Temp_Month_End_Tags
(
  month_id INT64 NOT NULL,
  acct_id NUMERIC(29),
  acct_tag_seq INT64,
  tag_id STRING,
  tag_history_seq INT64,
  month_end_date DATETIME
)
;
