CREATE TABLE IF NOT EXISTS EDW_TER.Fact_Ter_Month
(
  violatorid FLOAT64,
  termination_month STRING,
  termination_day_id INT64,
  termination_date DATE,
  txn_month STRING,
  txn_day_id INT64,
  partition_month INT64,
  curr_ind INT64 NOT NULL,
  invoice_toll_paid NUMERIC(33, 4),
  payment_amount NUMERIC(33, 4),
  remaining_balance_due NUMERIC(33, 4),
  txn_cnt FLOAT64,
  txn_toll_paid NUMERIC(33, 4)
)
;
