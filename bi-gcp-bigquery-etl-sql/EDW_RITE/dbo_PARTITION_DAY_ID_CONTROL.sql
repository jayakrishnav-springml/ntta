## Translation time: 2024-03-21T20:56:06.764423Z
## Translation job ID: e212c5d3-a7fa-4886-93b1-cb3be341e70a
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/EDW_RITE/Tables/dbo_PARTITION_DAY_ID_CONTROL.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_RITE.Partition_Day_Id_Control
(
  table_name STRING,
  day_id INT64,
  end_day_id INT64,
  startdate DATE,
  enddate DATE,
  partition_num INT64,
  current_ind INT64,
  update_flag INT64,
  flag_1 INT64,
  flag_2 INT64,
  flag_3 INT64,
  flag_4 INT64,
  flag_5 INT64,
  flag_6 INT64,
  flag_7 INT64,
  flag_8 INT64
)
cluster by day_id
;
