
CREATE TABLE IF NOT EXISTS EDW_TER.Payment_Plan_Invoices_Files
(
  load_file_name STRING NOT NULL,
  last_update_date DATETIME NOT NULL,
  instance_nbr INT64,
  violator_id INT64,
  acct_id INT64,
  primaryviolatorlname STRING,
  primaryviolatorfname STRING,
  secondaryviolatorfname STRING,
  secondaryviolatorlname STRING,
  phonenbr STRING,
  licplatenbr STRING,
  address1 STRING,
  address2 STRING,
  city STRING,
  state STRING,
  zipcode STRING,
  email STRING,
  remainingbalance NUMERIC(31, 2),
  monthlypaymentamount NUMERIC(31, 2),
  settlement_amount NUMERIC(31, 2),
  viol_invoice_id INT64,
  total_fee_due NUMERIC(31, 2),
  total_due NUMERIC(31, 2),
  duedate DATE,
  activeagreementdate DATE,
  lastpaymentdate DATE,
  invoice_id INT64,
  invoice_amount NUMERIC(31, 2),
  todaysdate DATE
)
;
