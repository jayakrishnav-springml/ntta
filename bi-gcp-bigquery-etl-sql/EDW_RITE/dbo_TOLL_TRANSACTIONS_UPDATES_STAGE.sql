## Translation time: 2024-03-21T20:56:06.764423Z
## Translation job ID: e212c5d3-a7fa-4886-93b1-cb3be341e70a
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/EDW_RITE/Tables/dbo_TOLL_TRANSACTIONS_UPDATES_STAGE.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_RITE.Toll_Transactions_Updates_Stage
(
  ttxn_id INT64,
  amount NUMERIC(31, 2) NOT NULL,
  transaction_date STRING,
  transaction_time_id INT64,
  credited_flag STRING,
  date_credited STRING,
  date_credited_time_id INT64,
  acct_id INT64,
  lane_id INT64 NOT NULL,
  vehicle_class_code STRING NOT NULL,
  tag_id STRING NOT NULL,
  posted_date STRING,
  posted_time_id INT64,
  transaction_file_detail_id NUMERIC(29),
  source_code STRING NOT NULL,
  source_trxn_id NUMERIC(29) NOT NULL,
  is_account_active INT64 NOT NULL,
  trans_type_id NUMERIC(29),
  last_update_type STRING,
  last_update_date DATETIME
)
;
