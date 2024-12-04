CREATE TABLE IF NOT EXISTS EDW_TER.Fact_Ter_Summary_Old
(
  violatorid INT64 NOT NULL,
  vidseq INT64 NOT NULL,
  paymentplan STRING NOT NULL,
  disputed STRING NOT NULL,
  tt_pmt_type STRING NOT NULL,
  tt_acct_bal STRING NOT NULL,
  termletter STRING NOT NULL,
  hv_removal STRING NOT NULL,
  state STRING NOT NULL,
  determinationletter STRING NOT NULL,
  banletter STRING NOT NULL,
  ban STRING NOT NULL,
  vrbletter STRING NOT NULL,
  vrb STRING NOT NULL,
  out_bal STRING NOT NULL,
  bal_amt NUMERIC(31, 2) NOT NULL,
  invoiceamount NUMERIC(31, 2) NOT NULL,
  invoiceamountdisc NUMERIC(31, 2) NOT NULL,
  tollsdue NUMERIC(31, 2) NOT NULL,
  feesdue NUMERIC(31, 2) NOT NULL,
  amountpaid NUMERIC(31, 2) NOT NULL
)
;