## Translation time: 2024-03-21T20:56:06.764423Z
## Translation job ID: e212c5d3-a7fa-4886-93b1-cb3be341e70a
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/EDW_RITE/Tables/dbo_ICRS_VPS_XREF.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_RITE.Icrs_Vps_Xref
(
  lane_viol_id NUMERIC(29),
  violation_id BIGNUMERIC(48, 10),
  transaction_id NUMERIC(29),
  status_flag INT64
)
;
