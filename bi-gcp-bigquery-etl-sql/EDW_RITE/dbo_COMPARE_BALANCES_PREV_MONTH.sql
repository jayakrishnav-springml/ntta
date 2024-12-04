## Translation time: 2024-03-21T20:56:06.764423Z
## Translation job ID: e212c5d3-a7fa-4886-93b1-cb3be341e70a
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/EDW_RITE/Tables/dbo_COMPARE_BALANCES_PREV_MONTH.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_RITE.Compare_Balances_Prev_Month
(
  acct_id NUMERIC(29) NOT NULL,
  old_balance NUMERIC(31, 2),
  new_balance BIGNUMERIC(40, 2),
  diff BIGNUMERIC(40, 2),
  debit BIGNUMERIC(40, 2),
  credit BIGNUMERIC(40, 2),
  old_balance_on_pm NUMERIC(31, 2),
  new_balance_on_pm BIGNUMERIC(40, 2)
)
;
