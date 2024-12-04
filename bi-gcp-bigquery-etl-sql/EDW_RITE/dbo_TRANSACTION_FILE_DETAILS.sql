## Translation time: 2024-03-21T20:56:06.764423Z
## Translation job ID: e212c5d3-a7fa-4886-93b1-cb3be341e70a
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/EDW_RITE/Tables/dbo_TRANSACTION_FILE_DETAILS.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_RITE.Transaction_File_Details
(
  transaction_file_detail_id NUMERIC(29),
  subs_trans_type_code STRING,
  transaction_file_header_id NUMERIC(29),
  subscriber_unique_id NUMERIC(29),
  received_date DATETIME,
  received_date_time_id INT64,
  insert_date DATETIME,
  last_update_date DATETIME
)
cluster by transaction_file_detail_id
;
