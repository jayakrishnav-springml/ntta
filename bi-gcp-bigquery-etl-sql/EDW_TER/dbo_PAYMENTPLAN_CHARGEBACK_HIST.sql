
CREATE TABLE IF NOT EXISTS EDW_TER.PaymentPlan_ChargeBack_Hist
(
  generation_date DATE,
  paymentplanid INT64 NOT NULL,
  activeagreementdate DATETIME,
  planstartdate DATETIME NOT NULL,
  firstpaymentdate DATETIME NOT NULL,
  lastpaymentdate DATETIME NOT NULL,
  payment_date DATETIME NOT NULL,
  payment BIGNUMERIC(40, 2) NOT NULL,
  transaction_type STRING NOT NULL,
  pos_name STRING,
  payment_source STRING,
  delivery STRING,
  payment_form STRING
)
;