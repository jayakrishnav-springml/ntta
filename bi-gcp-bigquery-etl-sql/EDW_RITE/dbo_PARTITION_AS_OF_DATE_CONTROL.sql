## Translation time: 2024-03-21T20:56:06.764423Z
## Translation job ID: e212c5d3-a7fa-4886-93b1-cb3be341e70a
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/EDW_RITE/Tables/dbo_PARTITION_AS_OF_DATE_CONTROL.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_RITE.Partition_As_Of_Date_Control
(
  partition_date DATE NOT NULL,
  data_as_of_date DATE NOT NULL,
  keep_partition_ind INT64 NOT NULL,
  current_ind STRING NOT NULL
)
cluster by partition_date
;
