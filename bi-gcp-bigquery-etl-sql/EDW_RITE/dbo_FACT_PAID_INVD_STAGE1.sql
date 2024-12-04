## Translation time: 2024-03-21T20:56:06.764423Z
## Translation job ID: e212c5d3-a7fa-4886-93b1-cb3be341e70a
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/EDW_RITE/Tables/dbo_FACT_PAID_INVD_STAGE1.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_RITE.Fact_Paid_Invd_Stage1
(
  day_id STRING,
  lane_id INT64,
  category STRING NOT NULL,
  txn_cnt INT64,
  act_rev BIGNUMERIC(40, 2),
  pos_rev BIGNUMERIC(40, 2)
)
;
