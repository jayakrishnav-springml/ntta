## Translation time: 2024-03-21T20:56:06.764423Z
## Translation job ID: e212c5d3-a7fa-4886-93b1-cb3be341e70a
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/EDW_RITE/Tables/dbo_MONTHLY_LOAD_CHECK_SOURCE_TABLES.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_RITE.Monthly_Load_Check_Source_Tables
(
  check_number INT64 NOT NULL,
  table_name STRING NOT NULL,
  filter_pattern STRING NOT NULL,
  field_name STRING NOT NULL,
  field_value INT64
)
;
