## Translation time: 2024-03-21T20:56:06.764423Z
## Translation job ID: e212c5d3-a7fa-4886-93b1-cb3be341e70a
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/EDW_RITE/Tables/stage_cal_mxm_wk_prd.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_RITE.Stage_Cal_Mxm_Wk_Prd
(
  cal_id INT64,
  cal_wk_bgn DATE,
  cal_prd_bgn DATE,
  etl_sid INT64,
  etl_chg STRING
)
;
