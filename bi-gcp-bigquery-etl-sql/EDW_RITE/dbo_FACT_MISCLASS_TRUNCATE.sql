## Translation time: 2024-03-21T20:56:06.764423Z
## Translation job ID: e212c5d3-a7fa-4886-93b1-cb3be341e70a
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/EDW_RITE/Tables/dbo_FACT_MISCLASS_TRUNCATE.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_RITE.Fact_Misclass_Truncate
(
  ttxn_id NUMERIC(29) NOT NULL,
  acct_id NUMERIC(29) NOT NULL,
  tag_id STRING NOT NULL,
  first_name STRING,
  last_name STRING,
  company_name STRING,
  transaction_date DATETIME NOT NULL,
  day_id STRING,
  hh STRING,
  amount NUMERIC(31, 2) NOT NULL,
  daily_mode_tag_toll NUMERIC(31, 2),
  tag_class_code STRING,
  vehicle_class_code STRING,
  daily_mode_vehicle_class INT64,
  issue STRING,
  agency_id STRING NOT NULL,
  lane_id INT64 NOT NULL,
  source_code STRING NOT NULL,
  source_trxn_id NUMERIC(29) NOT NULL,
  credited_flag STRING,
  lic_state STRING,
  lic_plate STRING,
  image_1 STRING,
  image_2 STRING,
  image_3 STRING,
  image_4 STRING,
  image_5 STRING,
  image_6 STRING
)
;
