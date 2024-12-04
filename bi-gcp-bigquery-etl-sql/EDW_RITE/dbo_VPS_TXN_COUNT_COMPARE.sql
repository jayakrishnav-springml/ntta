## Translation time: 2024-03-21T20:56:06.764423Z
## Translation job ID: e212c5d3-a7fa-4886-93b1-cb3be341e70a
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/EDW_RITE/Tables/dbo_VPS_TXN_COUNT_COMPARE.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_RITE.Vps_Txn_Count_Compare
(
  data_as_of DATETIME NOT NULL,
  lnd_txn_yy_mm INT64,
  lnd_txn_cnt INT64,
  edw_txn_yy_mm INT64,
  edw_txn_cnt INT64
)
;
