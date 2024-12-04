CREATE TABLE IF NOT EXISTS EDW_TER.Fact_Ter_Payment
(
  paymentplanid INT64 NOT NULL,
  violator_id INT64 NOT NULL,
  vidseq INT64 NOT NULL,
  last_invoice_id INT64 NOT NULL,
  vbi_invoice_id INT64 NOT NULL,
  viol_invoice_id INT64 NOT NULL,
  payment_date DATE NOT NULL,
  payment_mth INT64 NOT NULL,
  defaulteddate DATE NOT NULL,
  paidinfulldate DATE NOT NULL,
  bankruptcydate DATE NOT NULL,
  firstpaymentdate DATE NOT NULL,
  late_payment_flag INT64 NOT NULL,
  pmnt_before_defaulted STRING NOT NULL,
  pmnt_before_paidinfull STRING NOT NULL,
  pmnt_before_bankruptcy STRING NOT NULL,
  pos_id INT64 NOT NULL,
  split_amount NUMERIC(31, 2) NOT NULL,
  vtoll_amount NUMERIC(31, 2) NOT NULL,
  downpayment NUMERIC(31, 2) NOT NULL
)
;
