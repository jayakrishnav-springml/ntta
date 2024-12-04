## Translation time: 2024-03-04T06:41:57.683170Z
## Translation job ID: 00dc6676-2c12-444a-b02a-71c7788bdc89
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/EDW_TRIPS/Tables/Ref_Dim_Date.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_TRIPS_SUPPORT.Dim_Date
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