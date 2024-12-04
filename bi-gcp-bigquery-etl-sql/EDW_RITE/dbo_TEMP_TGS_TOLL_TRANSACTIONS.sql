## Translation time: 2024-03-21T20:56:06.764423Z
## Translation job ID: e212c5d3-a7fa-4886-93b1-cb3be341e70a
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/EDW_RITE/Tables/dbo_TEMP_TGS_TOLL_TRANSACTIONS.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_RITE.Temp_Tgs_Toll_Transactions
(
  acct_id NUMERIC(29) NOT NULL,
  posted_date DATE,
  amount BIGNUMERIC(40, 2),
  toll_cnt INT64,
  amount_on_zero_hr BIGNUMERIC(40, 2),
  toll_cnt_on_zero_hr INT64
)
;
