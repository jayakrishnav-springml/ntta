## Translation time: 2024-03-21T20:56:06.764423Z
## Translation job ID: e212c5d3-a7fa-4886-93b1-cb3be341e70a
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/EDW_RITE/Tables/stage_cal_day.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_RITE.Stage_Cal_Day
(
  cal_id INT64,
  cal_day_bgn DATE,
  cal_day_end DATE,
  cal_day_typ_id INT64,
  cal_day_typ_grp_id INT64,
  cal_day_wk_bgn DATE,
  cal_day_prd_bgn DATE,
  cal_day_qtr_bgn DATE,
  cal_day_sea_bgn DATE,
  cal_day_yr_bgn DATE,
  cal_wk_bgn DATE,
  cal_wk_end DATE,
  cal_wk_prd_bgn DATE,
  cal_wk_qtr_bgn DATE,
  cal_wk_sea_bgn DATE,
  cal_wk_yr_bgn DATE,
  cal_prd_bgn DATE,
  cal_prd_end DATE,
  cal_prd_qtr_bgn DATE,
  cal_prd_sea_bgn DATE,
  cal_prd_yr_bgn DATE,
  cal_qtr_bgn DATE,
  cal_qtr_end DATE,
  cal_qtr_sea_bgn DATE,
  cal_qtr_yr_bgn DATE,
  cal_sea_bgn DATE,
  cal_sea_end DATE,
  cal_sea_yr_bgn DATE,
  cal_yr_bgn DATE,
  cal_yr_end DATE,
  cal_yr_leap INT64,
  cal_days_wk INT64,
  cal_day_wk INT64,
  cal_days_prd INT64,
  cal_day_prd INT64,
  cal_days_qtr INT64,
  cal_day_qtr INT64,
  cal_days_sea INT64,
  cal_day_sea INT64,
  cal_days_yr INT64,
  cal_day_yr INT64,
  cal_wks_prd INT64,
  cal_wk_prd INT64,
  cal_wks_qtr INT64,
  cal_wk_qtr INT64,
  cal_wks_sea INT64,
  cal_wk_sea INT64,
  cal_wks_yr INT64,
  cal_wk_yr INT64,
  cal_prds_qtr INT64,
  cal_prd_qtr INT64,
  cal_prds_sea INT64,
  cal_prd_sea INT64,
  cal_prds_yr INT64,
  cal_prd_yr INT64,
  cal_qtrs_sea INT64,
  cal_qtr_sea INT64,
  cal_qtrs_yr INT64,
  cal_qtr_yr INT64,
  cal_seas_yr INT64,
  cal_sea_yr INT64,
  cal_day_sid STRING,
  cal_day_typ_sid STRING,
  cal_day_typ_grp_sid STRING,
  cal_wk_sid STRING,
  cal_prd_sid STRING,
  cal_qtr_sid STRING,
  cal_sea_sid STRING,
  cal_yr_sid STRING,
  cal_day_wk_sid STRING,
  cal_day_prd_sid STRING,
  cal_day_qtr_sid STRING,
  cal_day_sea_sid STRING,
  cal_day_yr_sid STRING,
  cal_wk_prd_sid STRING,
  cal_wk_qtr_sid STRING,
  cal_wk_sea_sid STRING,
  cal_wk_yr_sid STRING,
  cal_prd_qtr_sid STRING,
  cal_prd_sea_sid STRING,
  cal_prd_yr_sid STRING,
  cal_qtr_sea_sid STRING,
  cal_qtr_yr_sid STRING,
  cal_sea_yr_sid STRING,
  cal_day_desc_1 STRING,
  cal_day_typ_desc_1 STRING,
  cal_day_typ_grp_desc_1 STRING,
  cal_wk_desc_1 STRING,
  cal_prd_desc_1 STRING,
  cal_qtr_desc_1 STRING,
  cal_sea_desc_1 STRING,
  cal_yr_desc_1 STRING,
  cal_day_wk_desc_1 STRING,
  cal_day_prd_desc_1 STRING,
  cal_day_qtr_desc_1 STRING,
  cal_day_sea_desc_1 STRING,
  cal_day_yr_desc_1 STRING,
  cal_wk_prd_desc_1 STRING,
  cal_wk_qtr_desc_1 STRING,
  cal_wk_sea_desc_1 STRING,
  cal_wk_yr_desc_1 STRING,
  cal_prd_qtr_desc_1 STRING,
  cal_prd_sea_desc_1 STRING,
  cal_prd_yr_desc_1 STRING,
  cal_qtr_sea_desc_1 STRING,
  cal_qtr_yr_desc_1 STRING,
  cal_sea_yr_desc_1 STRING,
  cal_day_desc_2 STRING,
  cal_day_typ_desc_2 STRING,
  cal_day_typ_grp_desc_2 STRING,
  cal_wk_desc_2 STRING,
  cal_prd_desc_2 STRING,
  cal_qtr_desc_2 STRING,
  cal_sea_desc_2 STRING,
  cal_yr_desc_2 STRING,
  cal_day_wk_desc_2 STRING,
  cal_day_prd_desc_2 STRING,
  cal_day_qtr_desc_2 STRING,
  cal_day_sea_desc_2 STRING,
  cal_day_yr_desc_2 STRING,
  cal_wk_prd_desc_2 STRING,
  cal_wk_qtr_desc_2 STRING,
  cal_wk_sea_desc_2 STRING,
  cal_wk_yr_desc_2 STRING,
  cal_prd_qtr_desc_2 STRING,
  cal_prd_sea_desc_2 STRING,
  cal_prd_yr_desc_2 STRING,
  cal_qtr_sea_desc_2 STRING,
  cal_qtr_yr_desc_2 STRING,
  cal_sea_yr_desc_2 STRING,
  etl_sid INT64,
  etl_chg STRING
)
;
