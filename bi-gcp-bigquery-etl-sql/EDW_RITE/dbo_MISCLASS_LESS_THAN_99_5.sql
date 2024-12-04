## Translation time: 2024-03-21T20:56:06.764423Z
## Translation job ID: e212c5d3-a7fa-4886-93b1-cb3be341e70a
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/EDW_RITE/Tables/dbo_MISCLASS_LESS_THAN_99_5.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_RITE.Misclass_Less_Than_99_5
(
  day_id INT64,
  lane_id NUMERIC(29),
  plaza_name STRING,
  lane_abbrev STRING,
  day DATE,
  misclass INT64,
  total_txn INT64,
  percent BIGNUMERIC(57, 19)
)
;
