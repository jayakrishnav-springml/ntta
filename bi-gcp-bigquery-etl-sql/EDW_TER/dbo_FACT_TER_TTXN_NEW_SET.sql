CREATE TABLE IF NOT EXISTS EDW_TER.Fact_Ter_Ttxn_New_Set
(
  paymentplanid INT64 NOT NULL,
  violatorid INT64,
  vidseq INT64,
  source_code STRING NOT NULL,
  month_id INT64,
  ttxn_amount BIGNUMERIC(40, 2)
)
;