## Translation time: 2024-03-21T20:56:06.764423Z
## Translation job ID: e212c5d3-a7fa-4886-93b1-cb3be341e70a
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/EDW_RITE/Tables/dbo_TA_REV_TFC_EVTS.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_RITE.Ta_Rev_Tfc_Evts
(
  partition_values INT64,
  txn_id NUMERIC(29),
  date_time DATETIME NOT NULL,
  earned_rev NUMERIC(31, 2),
  actual_rev NUMERIC(31, 2),
  actual_axles INT64,
  creation_date DATETIME NOT NULL,
  tart_id NUMERIC(29),
  opnm_id NUMERIC(29),
  taoc_id NUMERIC(29),
  facs_id NUMERIC(29),
  plaz_id NUMERIC(29),
  lane_id NUMERIC(29),
  taob_id NUMERIC(29),
  txid_id NUMERIC(29),
  pmty_id NUMERIC(29),
  vcly_id NUMERIC(29),
  tauo_id NUMERIC(29),
  earned_axles INT64,
  transaction_file_detail_id NUMERIC(29),
  last_update_date DATETIME,
  last_update_type STRING
)
;
