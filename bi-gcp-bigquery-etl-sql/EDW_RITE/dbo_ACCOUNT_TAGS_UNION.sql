## Translation time: 2024-03-21T20:56:06.764423Z
## Translation job ID: e212c5d3-a7fa-4886-93b1-cb3be341e70a
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/EDW_RITE/Tables/dbo_ACCOUNT_TAGS_UNION.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_RITE.Account_Tags_Union
(
  acct_id NUMERIC(29),
  tag_id STRING,
  lic_plate STRING,
  lic_state STRING,
  assigned_date DATETIME,
  current_flag INT64,
  expired_date DATETIME
)
;
