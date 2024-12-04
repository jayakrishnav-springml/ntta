## Translation time: 2024-03-21T20:56:06.764423Z
## Translation job ID: e212c5d3-a7fa-4886-93b1-cb3be341e70a
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/EDW_RITE/Tables/dbo_FACT_PAID_INVD.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_RITE.Fact_Paid_Invd
(
  day_id INT64,
  lane_id INT64,
  vcly_id INT64 NOT NULL,
  vehicle_class INT64 NOT NULL,
  category STRING NOT NULL,
  txn_cnt INT64,
  act_rev NUMERIC(31, 2),
  pos_rev NUMERIC(31, 2)
)
CLUSTER BY day_id, lane_id, vcly_id;
