## Translation time: 2024-03-04T06:41:57.683170Z
## Translation job ID: 00dc6676-2c12-444a-b02a-71c7788bdc89
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/EDW_TRIPS/Tables/Ref_Dim_Month.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_TRIPS_SUPPORT.Dim_Month
(
  cal_monthid INT64 NOT NULL,
  sps_monthid INT64 NOT NULL,
  monthdate DATE,
  monthdesc STRING,
  cal_monthofyear INT64,
  sps_monthofyear INT64,
  cal_quarterid INT64,
  sps_quarterid INT64,
  cal_yearid INT64,
  sps_yearid INT64,
  monthduration INT64,
  prevmonthid INT64,
  cal_lqmonthid INT64,
  sps_lqmonthid INT64,
  lymonthid INT64,
  p2monthdesc STRING,
  p3monthid INT64,
  p3monthdesc STRING,
  p4monthid INT64,
  p4monthdesc STRING,
  p5monthid INT64,
  p5monthdesc STRING,
  p6monthid INT64,
  p6monthdesc STRING,
  p7monthid INT64,
  p7monthdesc STRING,
  p8monthid INT64,
  p8monthdesc STRING,
  p9monthid INT64,
  p9monthdesc STRING,
  p10monthid INT64,
  p10monthdesc STRING,
  p11monthid INT64,
  p11monthdesc STRING,
  p12monthid INT64,
  p12monthdesc STRING,
  prevlymonthid INT64,
  lyp3monthid INT64,
  lyp4monthid INT64,
  lyp5monthid INT64,
  lyp6monthid INT64,
  lyp7monthid INT64,
  lyp8monthid INT64,
  lyp9monthid INT64,
  lyp10monthid INT64,
  lyp11monthid INT64,
  lyp12monthid INT64
)
cluster by Cal_MonthID
;