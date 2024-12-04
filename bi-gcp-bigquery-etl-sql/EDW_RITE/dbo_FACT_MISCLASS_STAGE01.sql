## Translation time: 2024-03-21T20:56:06.764423Z
## Translation job ID: e212c5d3-a7fa-4886-93b1-cb3be341e70a
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/EDW_RITE/Tables/dbo_FACT_MISCLASS_STAGE01.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_RITE.Fact_Misclass_Stage01
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
  posted_date DATETIME,
  amount NUMERIC(31, 2) NOT NULL,
  agency_id STRING NOT NULL,
  plaza_id NUMERIC(29) NOT NULL,
  lane_id INT64 NOT NULL,
  source_code STRING NOT NULL,
  source_trxn_id NUMERIC(29) NOT NULL,
  credited_flag STRING,
  vehicle_class_code STRING,
  tag_class_code STRING,
  lic_state STRING,
  lic_plate STRING,
  assigned_date DATETIME,
  expired_date DATETIME,
  acct_tag_seq INT64,
  tag_history_seq INT64,
  acct_tag_status STRING
)
;
