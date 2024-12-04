## Translation time: 2024-03-21T20:56:06.764423Z
## Translation job ID: e212c5d3-a7fa-4886-93b1-cb3be341e70a
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/EDW_RITE/Tables/dbo_FACT_TRANSACTION_SUMMARY.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_RITE.Fact_Transaction_Summary
(
  zc_tt_acct_id NUMERIC(29),
  toll_tag_trans_count INT64,
  zc_trans_count INT64,
  transactiontype STRING NOT NULL,
  transaction_date DATETIME NOT NULL,
  transaction_time_id INT64,
  zip_code STRING,
  zipcode_latitude BIGNUMERIC(50, 12),
  zipcode_longitude BIGNUMERIC(50, 12),
  county STRING,
  county_group STRING,
  acct_status_descr STRING,
  acct_tag_status_descr STRING,
  lane_id NUMERIC(29),
  viol_status STRING NOT NULL
)
;
