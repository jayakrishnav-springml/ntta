CREATE TABLE IF NOT EXISTS EDW_TER.Dim_Hv_Non_Hv
(
  hv_non_hv_ind INT64 NOT NULL,
  hv_non_hv_desc STRING NOT NULL
)
CLUSTER BY hv_non_hv_ind
;
