## Translation time: 2024-03-21T20:56:06.764423Z
## Translation job ID: e212c5d3-a7fa-4886-93b1-cb3be341e70a
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/EDW_RITE/Tables/dbo_VPS_HOST_TRANSACTIONS_STAGE_1.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_RITE.Vps_Host_Transactions_Stage_1
(
  transaction_id INT64,
  violation_id INT64,
  lane_viol_id INT64 NOT NULL
)
;
