## Translation time: 2024-03-04T06:41:57.683170Z
## Translation job ID: 00dc6676-2c12-444a-b02a-71c7788bdc89
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/EDW_TRIPS/Tables/Ref_Dim_Day.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_TRIPS_SUPPORT.Dim_Day
(
  daydate DATE NOT NULL,
  dayid INT64,
  prevdayid INT64,
  cal_monthid INT64,
  sps_monthid INT64,
  cal_quarterid INT64,
  sps_quarterid INT64,
  cal_yearid INT64,
  sps_yearid INT64,
  prevdaydate DATE,
  lmdaydate DATE,
  cal_lqdaydate DATE,
  sps_lqdaydate DATE,
  lydaydate DATE,
  cal_weekid INT64,
  sps_weekid INT64,
  cal_lwdaydate DATE,
  sps_lwdaydate DATE,
  daydesc STRING,
  prevdaydesc STRING,
  isworkday INT64,
  isweekday INT64,
  isweekend INT64,
  workdaysinmonth INT64,
  workdaysleftinmonth INT64,
  workdaysusedinmonth INT64,
  daysinmonth INT64,
  lastmodified DATE NOT NULL
)
cluster by daydate
;