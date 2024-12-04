## Translation time: 2024-03-21T20:56:06.764423Z
## Translation job ID: e212c5d3-a7fa-4886-93b1-cb3be341e70a
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/EDW_RITE/Tables/land_perm_cal.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_RITE.Land_Perm_Cal
(
  cal_id INT64 NOT NULL,
  cal_bgn DATE NOT NULL,
  cal_end DATE NOT NULL,
  cal_wk_day_end STRING NOT NULL,
  cal_days_nrml INT64 NOT NULL,
  cal_days_leap INT64 NOT NULL,
  cal_wks_nrml INT64 NOT NULL,
  cal_wks_leap INT64 NOT NULL,
  cal_prds_nrml INT64 NOT NULL,
  cal_prds_leap INT64 NOT NULL,
  cal_qtrs_nrml INT64 NOT NULL,
  cal_qtrs_leap INT64 NOT NULL,
  cal_seas_nrml INT64 NOT NULL,
  cal_seas_leap INT64 NOT NULL,
  cal_desc STRING NOT NULL
)
;
