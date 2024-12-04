## Translation time: 2024-03-21T20:56:06.764423Z
## Translation job ID: e212c5d3-a7fa-4886-93b1-cb3be341e70a
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/EDW_RITE/Tables/dbo_COMPARE_ACCT_BALANCE_SUMMARY.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_RITE.Compare_Acct_Balance_Summary
(
  acct_id NUMERIC(29) NOT NULL,
  bal_month_date DATE,
  posted_date_from DATETIME,
  posted_date_to DATETIME,
  rt_prev_month_bal NUMERIC(31, 2),
  tt_charges BIGNUMERIC(40, 2),
  rt_payments BIGNUMERIC(40, 2),
  rt_this_month_bal NUMERIC(31, 2),
  calc_this_month_bal BIGNUMERIC(40, 2),
  bal_diff BIGNUMERIC(40, 2),
  debit_prev_mon_zero_hr BIGNUMERIC(40, 2),
  credit_prev_mon_zero_hr BIGNUMERIC(40, 2),
  balance_prev_mon_zero_hr BIGNUMERIC(40, 2),
  debit_this_mon_zero_hr BIGNUMERIC(40, 2),
  credit_this_mon_zero_hr BIGNUMERIC(40, 2),
  balance_this_mon_zero_hr BIGNUMERIC(40, 2),
  tt_charges_normal BIGNUMERIC(40, 2),
  rt_payments_normal BIGNUMERIC(40, 2),
  calc_this_month_bal_normal BIGNUMERIC(40, 2),
  bal_diff_normal BIGNUMERIC(40, 2)
)
;
