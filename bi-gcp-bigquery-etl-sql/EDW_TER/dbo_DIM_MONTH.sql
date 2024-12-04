CREATE TABLE IF NOT EXISTS EDW_TER.Dim_Month
(
  month_id INT64 NOT NULL,
  month STRING NOT NULL,
  insert_datetime DATETIME NOT NULL
)
cluster by month_id
;