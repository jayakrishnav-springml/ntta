## Translation time: 2024-03-21T20:56:06.764423Z
## Translation job ID: e212c5d3-a7fa-4886-93b1-cb3be341e70a
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/EDW_RITE/Tables/dbo_FACT_TRIP.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_RITE.Fact_Trip
(
  acct_id NUMERIC(29) NOT NULL,
  tag_id STRING NOT NULL,
  day_id STRING,
  trip_amt FLOAT64,
  plaza_1 STRING,
  dir_1 STRING,
  txn_1 DATETIME,
  plaza_2 STRING,
  dir_2 STRING,
  txn_2 DATETIME,
  plaza_3 STRING,
  dir_3 STRING,
  txn_3 DATETIME,
  plaza_4 STRING,
  dir_4 STRING,
  txn_4 DATETIME,
  plaza_5 STRING,
  dir_5 STRING,
  txn_5 DATETIME,
  plaza_6 STRING,
  dir_6 STRING,
  txn_6 DATETIME,
  plaza_7 STRING,
  dir_7 STRING,
  txn_7 DATETIME,
  plaza_8 STRING,
  dir_8 STRING,
  txn_8 DATETIME,
  plaza_9 STRING,
  dir_9 STRING,
  txn_9 DATETIME,
  plaza_10 STRING,
  dir_10 STRING,
  txn_10 DATETIME
)
;
