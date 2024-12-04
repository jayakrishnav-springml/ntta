## Translation time: 2024-03-21T20:56:06.764423Z
## Translation job ID: e212c5d3-a7fa-4886-93b1-cb3be341e70a
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/EDW_RITE/Tables/dbo_DIM_QUARTER.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_RITE.Dim_Quarter
(
  cal_quarterid INT64 NOT NULL,
  sps_quarterid INT64 NOT NULL,
  quarterdate DATE,
  cal_quarterdesc STRING,
  sps_quarterdesc STRING,
  cal_yearid INT64,
  sps_yearid INT64,
  quarterduration INT64,
  cal_prevquarterid INT64,
  sps_prevquarterid INT64,
  cal_lyquarterid INT64,
  sps_lyquarterid INT64
)
cluster by cal_quarterid
;
