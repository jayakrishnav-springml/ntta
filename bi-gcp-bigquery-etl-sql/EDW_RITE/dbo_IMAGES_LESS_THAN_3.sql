## Translation time: 2024-03-21T20:56:06.764423Z
## Translation job ID: e212c5d3-a7fa-4886-93b1-cb3be341e70a
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/EDW_RITE/Tables/dbo_IMAGES_LESS_THAN_3.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_RITE.Images_Less_Than_3
(
  day_id INT64,
  lane_abbrev STRING,
  start_time DATETIME,
  end_time DATETIME,
  cnt INT64,
  total_txn INT64,
  percent BIGNUMERIC(57, 19)
)
;
