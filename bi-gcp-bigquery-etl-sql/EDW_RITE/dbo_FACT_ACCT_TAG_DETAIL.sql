## Translation time: 2024-03-21T20:56:06.764423Z
## Translation job ID: e212c5d3-a7fa-4886-93b1-cb3be341e70a
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/EDW_RITE/Tables/dbo_FACT_ACCT_TAG_DETAIL.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_RITE.Fact_Acct_Tag_Detail
(
  month_id INT64,
  acct_id NUMERIC(29),
  rebill_amt_grp_id INT64,
  rebill_amt NUMERIC(31, 2),
  acct_status_code STRING,
  acct_type_code STRING,
  pmt_type_code STRING,
  zip_code STRING,
  acct_created_date DATE,
  acct_closed_date DATE,
  tag_id STRING,
  acct_tag_seq INT64,
  tag_history_seq INT64,
  tag_counter STRING NOT NULL,
  tag_counter_date DATETIME,
  month_begin_tag INT64 NOT NULL,
  opened_tag INT64 NOT NULL,
  closed_tag INT64 NOT NULL,
  month_end_tag INT64 NOT NULL,
  last_update_date DATETIME NOT NULL
)
;
