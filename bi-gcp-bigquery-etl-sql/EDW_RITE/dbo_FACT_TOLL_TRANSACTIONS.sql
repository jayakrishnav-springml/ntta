## Translation time: 2024-03-21T20:56:06.764423Z
## Translation job ID: e212c5d3-a7fa-4886-93b1-cb3be341e70a
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/EDW_RITE/Tables/dbo_FACT_TOLL_TRANSACTIONS.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_RITE.Fact_Toll_Transactions
(
  day_id INT64,
  month_id INT64,
  ttxn_id INT64 NOT NULL,
  amount NUMERIC(31, 2) NOT NULL,
  transaction_date DATETIME NOT NULL,
  transaction_time_id INT64,
  credited_flag STRING,
  date_credited DATE,
  date_credited_time_id INT64,
  acct_id INT64,
  agency_id STRING NOT NULL,
  lane_id INT64 NOT NULL,
  vehicle_class_code STRING NOT NULL,
  tt_id INT64,
  tag_id STRING NOT NULL,
  license_plate_id INT64,
  lic_plate STRING,
  lic_state STRING,
  posted_date DATE,
  posted_time_id INT64,
  transaction_file_detail_id NUMERIC(29),
  source_code STRING NOT NULL,
  source_trxn_id NUMERIC(29) NOT NULL,
  trans_type_id NUMERIC(29),
  last_update_type STRING,
  last_update_date DATETIME
)
CLUSTER BY source_trxn_id;
