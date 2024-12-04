## Translation time: 2024-03-21T20:56:06.764423Z
## Translation job ID: e212c5d3-a7fa-4886-93b1-cb3be341e70a
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/EDW_RITE/Tables/dbo_TA_TXN_CLASS_DATAS.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_RITE.Ta_Txn_Class_Datas
(
  partition_values INT64,
  rev_axle_ct NUMERIC(29),
  att_axles INT64,
  att_class NUMERIC(29),
  att_fare NUMERIC(31, 2),
  pre_axles INT64,
  pre_class NUMERIC(29),
  pre_fare NUMERIC(31, 2),
  mid_loop_cts NUMERIC(29),
  entry_loop_cts NUMERIC(29),
  exit_loop_cts NUMERIC(29),
  unusual_occ_cd STRING,
  discrepancy STRING,
  cd_id NUMERIC(29) NOT NULL,
  tart_id NUMERIC(29) NOT NULL,
  fwd_axle_ct NUMERIC(29),
  fwd_axles NUMERIC(29),
  last_update_type STRING NOT NULL,
  last_update_date DATETIME NOT NULL
)
;
