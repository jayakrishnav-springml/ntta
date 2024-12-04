## Translation time: 2024-03-21T20:56:06.764423Z
## Translation job ID: e212c5d3-a7fa-4886-93b1-cb3be341e70a
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/EDW_RITE/Tables/dbo_DIM_DATE.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_RITE.Dim_Date
(
  date DATE NOT NULL,
  month_week STRING,
  date_day STRING NOT NULL,
  date_full STRING,
  date_month STRING NOT NULL,
  date_year_month STRING,
  date_quarter STRING NOT NULL,
  date_year STRING NOT NULL,
  day_of_week_name STRING,
  business_day STRING,
  weekend STRING,
  holiday STRING,
  holiday_name STRING
)
cluster by date
;
