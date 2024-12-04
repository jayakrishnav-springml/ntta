## Translation time: 2024-03-21T20:56:06.764423Z
## Translation job ID: e212c5d3-a7fa-4886-93b1-cb3be341e70a
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/EDW_RITE/Tables/dbo_MANUAL_VIOLATIONS_ID_LANE_VIOL_ID_XREF.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_RITE.Manual_Violations_Id_Lane_Viol_Id_Xref
(
  lane_viol_id NUMERIC(29),
  violation_id INT64
)
cluster by violation_id
;
