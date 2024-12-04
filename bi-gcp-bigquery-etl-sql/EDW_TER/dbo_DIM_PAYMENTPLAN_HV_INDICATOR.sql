CREATE TABLE IF NOT EXISTS EDW_TER.Dim_PaymentPlan_Hv_Indicator
(
  indicator_id INT64 NOT NULL,
  pp_hv_flag STRING NOT NULL
)
cluster by indicator_id
;