## Translation time: 2024-03-21T20:56:06.764423Z
## Translation job ID: e212c5d3-a7fa-4886-93b1-cb3be341e70a
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/EDW_RITE/Tables/dbo_RETAIL_TRXN_DETAILS.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_RITE.Retail_Trxn_Details
(
  rtd_id INT64,
  trans_date DATETIME,
  trans_status STRING,
  date_created DATETIME,
  trans_type_id NUMERIC(29),
  retail_trans_id INT64,
  credit_src_id1 NUMERIC(29),
  insert_date DATETIME,
  last_update_date DATETIME
)
;
