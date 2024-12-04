## Translation time: 2024-03-21T20:56:06.764423Z
## Translation job ID: e212c5d3-a7fa-4886-93b1-cb3be341e70a
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/EDW_RITE/Tables/stage_cal_wk.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_RITE.Stage_Cal_Wk
(
  cal_id INT64,
  cal_wk_bgn DATE,
  cal_wk_end DATE,
  cal_wk_prd_bgn DATE,
  cal_wk_qtr_bgn DATE,
  cal_wk_sea_bgn DATE,
  cal_wk_yr_bgn DATE,
  cal_yr_bgn DATE,
  cal_yr_end DATE,
  cal_yr_leap INT64,
  cal_wks_prd INT64,
  cal_wk_prd INT64,
  cal_wks_qtr INT64,
  cal_wk_qtr INT64,
  cal_wks_sea INT64,
  cal_wk_sea INT64,
  cal_wks_yr INT64,
  cal_wk_yr INT64,
  cal_wk_sid STRING,
  cal_yr_sid STRING,
  cal_wk_prd_sid STRING,
  cal_wk_qtr_sid STRING,
  cal_wk_sea_sid STRING,
  cal_wk_yr_sid STRING,
  cal_wk_desc_1 STRING,
  cal_yr_desc_1 STRING,
  cal_wk_prd_desc_1 STRING,
  cal_wk_qtr_desc_1 STRING,
  cal_wk_sea_desc_1 STRING,
  cal_wk_yr_desc_1 STRING,
  cal_wk_desc_2 STRING,
  cal_yr_desc_2 STRING,
  cal_wk_prd_desc_2 STRING,
  cal_wk_qtr_desc_2 STRING,
  cal_wk_sea_desc_2 STRING,
  cal_wk_yr_desc_2 STRING,
  etl_sid INT64,
  etl_chg STRING
)
;
