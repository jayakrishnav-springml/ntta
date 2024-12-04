## Translation time: 2024-03-21T20:56:06.764423Z
## Translation job ID: e212c5d3-a7fa-4886-93b1-cb3be341e70a
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/EDW_RITE/Tables/dbo_COMPARE_ACCT_BALANCE_DETAIL.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_RITE.Compare_Acct_Balance_Detail
(
  acct_id NUMERIC(29) NOT NULL,
  posted_date DATE,
  toll_cnt BIGNUMERIC(40, 2) NOT NULL,
  debit BIGNUMERIC(40, 2) NOT NULL,
  credit BIGNUMERIC(40, 2) NOT NULL,
  begin_balance BIGNUMERIC(40, 2),
  end_balance BIGNUMERIC(40, 2),
  posted_balance NUMERIC(31, 2),
  bal_diff BIGNUMERIC(40, 2),
  toll_cnt_on_zero_hr INT64 NOT NULL,
  debit_on_zero_hr BIGNUMERIC(40, 2) NOT NULL,
  credit_on_zero_hr BIGNUMERIC(40, 2) NOT NULL,
  balance_on_zero_hr BIGNUMERIC(40, 2) NOT NULL
)
;
