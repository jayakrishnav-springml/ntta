
CREATE TABLE IF NOT EXISTS EDW_TER.Fact_Ter_Summary_Prev
(
  violatorid INT64,
  vidseq INT64,
  state STRING NOT NULL,
  disputed STRING NOT NULL,
  determinationletter STRING NOT NULL,
  banletter STRING NOT NULL,
  ban STRING NOT NULL,
  vrbletter STRING NOT NULL,
  vrb STRING NOT NULL,
  paymentplan STRING NOT NULL,
  tt_pmt_type STRING,
  tt_acct_bal STRING,
  bal_amt NUMERIC(33, 4) NOT NULL,
  out_bal STRING NOT NULL,
  invoiceamount NUMERIC(33, 4) NOT NULL,
  invoiceamountdisc NUMERIC(33, 4) NOT NULL,
  tollsdue NUMERIC(33, 4) NOT NULL,
  feesdue NUMERIC(33, 4) NOT NULL,
  amountpaid BIGNUMERIC(40, 2) NOT NULL
)
;