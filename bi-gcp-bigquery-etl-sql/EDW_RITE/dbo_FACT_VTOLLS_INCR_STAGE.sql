## Translation time: 2024-03-21T20:56:06.764423Z
## Translation job ID: e212c5d3-a7fa-4886-93b1-cb3be341e70a
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/EDW_RITE/Tables/dbo_FACT_VTOLLS_INCR_STAGE.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_RITE.Fact_Vtolls_Incr_Stage
(
  day_id INT64,
  lane_id INT64,
  vcly_id NUMERIC(29) NOT NULL,
  vehicle_class NUMERIC(29),
  source_code STRING NOT NULL,
  disposition STRING NOT NULL,
  txn_cnt INT64,
  pos_rev BIGNUMERIC(40, 2),
  act_rev BIGNUMERIC(40, 2)
)
;
