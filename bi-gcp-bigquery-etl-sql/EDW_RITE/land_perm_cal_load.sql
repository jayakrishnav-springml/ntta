## Translation time: 2024-03-21T20:56:06.764423Z
## Translation job ID: e212c5d3-a7fa-4886-93b1-cb3be341e70a
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/EDW_RITE/Tables/land_perm_cal_load.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_RITE.Land_Perm_Cal_Load
(
  cal_dflt_day_bgn DATE NOT NULL,
  cal_dflt_day_end DATE NOT NULL
)
;