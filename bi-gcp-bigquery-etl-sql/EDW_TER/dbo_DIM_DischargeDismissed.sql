CREATE TABLE IF NOT EXISTS EDW_TER.Dim_DischargeDismissed
(
  dischargedismissedid INT64 NOT NULL,
  dischargedismissed STRING NOT NULL,
  insert_datetime DATETIME NOT NULL
)
cluster by dischargedismissedid
;
