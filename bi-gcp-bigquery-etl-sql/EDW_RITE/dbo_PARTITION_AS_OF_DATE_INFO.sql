## Translation time: 2024-03-21T20:56:06.764423Z
## Translation job ID: e212c5d3-a7fa-4886-93b1-cb3be341e70a
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/EDW_RITE/Tables/dbo_PARTITION_AS_OF_DATE_INFO.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_RITE.Partition_As_Of_Date_Info
(
  table_name STRING NOT NULL,
  partition_nbr INT64,
  range_from_excluding DATE,
  range_to_including DATE,
  insert_date DATETIME NOT NULL
)
cluster by partition_nbr
;
