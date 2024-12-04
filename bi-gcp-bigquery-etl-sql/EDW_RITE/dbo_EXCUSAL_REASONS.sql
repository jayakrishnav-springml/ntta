## Translation time: 2024-03-21T20:56:06.764423Z
## Translation job ID: e212c5d3-a7fa-4886-93b1-cb3be341e70a
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/EDW_RITE/Tables/dbo_EXCUSAL_REASONS.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_RITE.Excusal_Reasons
(
  excused_reason STRING NOT NULL,
  excused_reas_descr STRING NOT NULL,
  excused_reas_order INT64,
  supervisor_only STRING NOT NULL,
  is_active STRING NOT NULL,
  excuse_toll STRING NOT NULL,
  excuse_fine STRING NOT NULL,
  last_update_date DATETIME,
  last_update_type STRING
)
;
