## Translation time: 2024-03-21T20:56:06.764423Z
## Translation job ID: e212c5d3-a7fa-4886-93b1-cb3be341e70a
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/EDW_RITE/Tables/dbo_ITEM29_LND_LG_VPS_STAGE.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_RITE.Item29_Lnd_Lg_Vps_Stage
(
  partition_date DATE,
  data_as_of_date DATE,
  txn_date DATE,
  lane_id NUMERIC(29) NOT NULL,
  category STRING,
  txn_cnt FLOAT64,
  revenue NUMERIC(33, 4),
  bubl_source_desc STRING NOT NULL
)
;
