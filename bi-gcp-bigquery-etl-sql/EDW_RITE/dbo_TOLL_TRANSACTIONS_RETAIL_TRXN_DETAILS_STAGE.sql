## Translation time: 2024-03-21T20:56:06.764423Z
## Translation job ID: e212c5d3-a7fa-4886-93b1-cb3be341e70a
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/EDW_RITE/Tables/dbo_TOLL_TRANSACTIONS_RETAIL_TRXN_DETAILS_STAGE.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_RITE.Toll_Transactions_Retail_Trxn_Details_Stage
(
  credit_src_id1 INT64
)
cluster by credit_src_id1
;
