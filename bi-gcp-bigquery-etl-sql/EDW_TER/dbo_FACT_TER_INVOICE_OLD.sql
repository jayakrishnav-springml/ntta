
CREATE TABLE IF NOT EXISTS EDW_TER.Fact_Ter_Invoice_Old
(
  last_invoice_id INT64 NOT NULL,
  paymentplanid INT64 NOT NULL,
  violator_id INT64 NOT NULL,
  vidseq INT64 NOT NULL,
  paymentplan_date DATE,
  planstart_date DATE,
  hvdate DATE,
  termdate DATE,
  date_excused DATETIME,
  vbi_invoice_id INT64 NOT NULL,
  viol_invoice_id INT64 NOT NULL,
  invoice_date DATE NOT NULL,
  invoice_status STRING NOT NULL,
  current_status STRING NOT NULL,
  pp_hv_flag INT64 NOT NULL,
  tolls_due NUMERIC(33, 4) NOT NULL,
  fees_due NUMERIC(33, 4) NOT NULL,
  invoice_amount NUMERIC(33, 4) NOT NULL,
  invoice_amount_disc NUMERIC(33, 4) NOT NULL,
  invoice_paid_amount NUMERIC(33, 4) NOT NULL,
  invoice_balance NUMERIC(33, 4) NOT NULL,
  invoice_paid_amount_asof_pp NUMERIC(33, 4) NOT NULL,
  invoice_balance_asof_pp NUMERIC(33, 4) NOT NULL
)
;