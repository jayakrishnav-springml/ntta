## Translation time: 2024-03-21T20:56:06.764423Z
## Translation job ID: e212c5d3-a7fa-4886-93b1-cb3be341e70a
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/EDW_RITE/Tables/dbo_PARTITION_LOAD_Dates.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_RITE.Partition_Load_Dates
(
  table_name STRING NOT NULL,
  day_id INT64,
  partition_num INT64,
  end_day_id INT64,
  indicat INT64
)
;
