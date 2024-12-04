## Translation time: 2024-03-21T20:56:06.764423Z
## Translation job ID: e212c5d3-a7fa-4886-93b1-cb3be341e70a
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/EDW_RITE/Tables/dbo_TEMP_TGS_TRANSACTIONS_SUMMARY.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_RITE.Temp_Tgs_Transactions_Summary
(
  acct_id NUMERIC(29),
  posted_date DATE,
  debit BIGNUMERIC(40, 2),
  credit BIGNUMERIC(40, 2),
  balance BIGNUMERIC(40, 2),
  toll_cnt BIGNUMERIC(40, 2),
  debit_on_zero_hr BIGNUMERIC(40, 2),
  credit_on_zero_hr BIGNUMERIC(40, 2),
  balance_on_zero_hr BIGNUMERIC(40, 2),
  toll_cnt_on_zero_hr INT64
)
;
