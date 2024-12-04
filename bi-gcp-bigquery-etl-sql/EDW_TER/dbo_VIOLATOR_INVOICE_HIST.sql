
CREATE TABLE IF NOT EXISTS EDW_TER.Violator_Invoice_Hist
(
  generation_date DATE,
  instancenbr INT64 NOT NULL,
  alt_violator_id INT64,
  ca_acct_id STRING NOT NULL,
  primaryviolatorlname STRING,
  primaryviolatorfname STRING,
  secondaryviolatorlname STRING,
  secondaryviolatorfname STRING,
  phonenbr STRING,
  licplatenbr STRING,
  address1 STRING,
  city STRING,
  address2 STRING NOT NULL,
  zipcode STRING,
  state STRING,
  email STRING NOT NULL,
  remainingbalance NUMERIC(33, 4),
  monthlypaymentamount NUMERIC(33, 4),
  viol_invoice_id NUMERIC(29),
  total_fee_due BIGNUMERIC(40, 2),
  activeagreementdate STRING,
  duedate STRING,
  lastinvoicenbr1 STRING,
  createddate DATETIME NOT NULL,
  createdby STRING NOT NULL,
  `settlement amount` NUMERIC(33, 4),
  agreementtype STRING,
  startdate DATE
)
;