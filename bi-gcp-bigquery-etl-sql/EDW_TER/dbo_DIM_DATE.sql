CREATE TABLE IF NOT EXISTS EDW_TER.Dim_Date
(
  date DATE NOT NULL,
  month_week STRING,
  date_day STRING NOT NULL,
  date_full STRING,
  date_month STRING NOT NULL,
  date_year_month STRING,
  date_quarter STRING NOT NULL,
  date_year STRING NOT NULL
)
;
