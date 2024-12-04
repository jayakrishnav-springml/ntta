## Translation time: 2024-03-21T20:56:06.764423Z
## Translation job ID: e212c5d3-a7fa-4886-93b1-cb3be341e70a
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/EDW_RITE/Tables/dbo_Service_Queries_For_Tables_In_Load_Process.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_RITE.Service_Queries_For_Tables_In_Load_Process
(
  num_id INT64 NOT NULL,
  schema_name STRING NOT NULL,
  table_name STRING NOT NULL,
  full_name STRING NOT NULL,
  stage_table_name STRING NOT NULL,
  new_set_table_name STRING,
  full_load_proc_name STRING,
  incr_load_proc_name STRING,
  number_of_rows INT64,
  load_process_id INT64,
  active INT64 NOT NULL,
  depending_tables_list STRING,
  use_last_update_date INT64 NOT NULL,
  use_partitions INT64 NOT NULL,
  identity_columns STRING,
  distribution_string STRING,
  index_string STRING,
  partition_string STRING,
  sql_columns STRING,
  sql_select STRING,
  sql_select_cast STRING,
  sql_where STRING,
  sql_stats STRING,
  sql_delete STRING,
  sql_insert STRING,
  sql_rename STRING,
  sql_create_as_select STRING,
  sql_create_truncate STRING,
  run_after_load STRING
)
;
