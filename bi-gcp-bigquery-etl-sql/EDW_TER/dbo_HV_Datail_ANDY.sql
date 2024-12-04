CREATE TABLE IF NOT EXISTS EDW_TER.Hv_Datail_Andy
(
  violatorid INT64 NOT NULL,
  hv_month DATE,
  hv INT64 NOT NULL,
  new_hv INT64 NOT NULL,
  paid_in_full INT64 NOT NULL,
  pay_plan INT64 NOT NULL,
  returning_hv INT64
)
;