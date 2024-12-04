CREATE TABLE IF NOT EXISTS EDW_TER.Dim_Year
(
  year_id INT64 NOT NULL,
  year STRING NOT NULL,
  insert_datetime DATETIME NOT NULL
)
cluster by year_id
;