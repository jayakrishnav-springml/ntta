## Translation time: 2024-03-21T20:56:06.764423Z
## Translation job ID: e212c5d3-a7fa-4886-93b1-cb3be341e70a
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/EDW_RITE/Tables/stage_cal_prd_qtr.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_RITE.Stage_Cal_Prd_Qtr
(
  cal_id INT64,
  cal_prd_qtr_bgn DATE,
  cal_prd_qtr_ix INT64,
  cal_prds_qtr INT64,
  cal_prd_qtr INT64,
  cal_prd_qtr_sid STRING,
  cal_prd_qtr_desc_1 STRING,
  cal_prd_qtr_desc_2 STRING,
  etl_sid INT64,
  etl_chg STRING
)
;
