## Translation time: 2024-03-21T20:56:06.764423Z
## Translation job ID: e212c5d3-a7fa-4886-93b1-cb3be341e70a
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/EDW_RITE/Tables/dbo_FACT_UNIFIED_VIOLATION_SNAPSHOT_DELETE_FROM_HISTORY.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_RITE.Fact_Unified_Violation_Snapshot_Delete_From_History
(
  tart_id NUMERIC(29) NOT NULL,
  month_id INT64,
  posted_date_diff STRING
)
CLUSTER BY tart_id;
