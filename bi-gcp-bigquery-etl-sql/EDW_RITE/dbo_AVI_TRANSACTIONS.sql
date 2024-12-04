## Translation time: 2024-03-21T20:56:06.764423Z
## Translation job ID: e212c5d3-a7fa-4886-93b1-cb3be341e70a
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/EDW_RITE/Tables/dbo_AVI_TRANSACTIONS.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_RITE.Avi_Transactions
(
  transaction_id NUMERIC(29) NOT NULL,
  transaction_date DATETIME NOT NULL,
  agency_code STRING NOT NULL,
  tag_id STRING NOT NULL,
  facility_id INT64 NOT NULL,
  plaza_id INT64 NOT NULL,
  lane_id NUMERIC(29) NOT NULL,
  disposition STRING,
  reason_code STRING,
  earned_class INT64,
  earned_revenue NUMERIC(33, 4),
  posted_class INT64,
  posted_revenue NUMERIC(33, 4),
  posted_date_time DATETIME,
  source_code STRING NOT NULL,
  txid_id STRING,
  creation_date DATETIME NOT NULL,
  acct_id NUMERIC(29),
  transaction_file_detail_id NUMERIC(29),
  last_update_type STRING NOT NULL,
  last_update_date DATETIME NOT NULL
)
;
