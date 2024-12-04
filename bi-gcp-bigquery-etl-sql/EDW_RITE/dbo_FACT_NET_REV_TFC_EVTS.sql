## Translation time: 2024-03-21T20:56:06.764423Z
## Translation job ID: e212c5d3-a7fa-4886-93b1-cb3be341e70a
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/EDW_RITE/Tables/dbo_FACT_NET_REV_TFC_EVTS.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_RITE.Fact_Net_Rev_Tfc_Evts
(
  day_id INT64,
  month_id INT64,
  tart_id INT64 NOT NULL,
  lane_id INT64,
  atd_id INT64,
  opnm_id INT64 NOT NULL,
  pmty_id INT64 NOT NULL,
  vcly_id INT64 NOT NULL,
  time_id INT64,
  date_time DATETIME NOT NULL,
  local_time DATETIME,
  ear_rev NUMERIC(31, 2),
  exp_rev NUMERIC(31, 2),
  act_rev NUMERIC(31, 2),
  att_fare NUMERIC(31, 2),
  misclass_ct INT64 NOT NULL,
  sign_flg INT64 NOT NULL,
  adj_status STRING NOT NULL,
  txid_id INT64,
  ves_serial_no INT64,
  ves_date_time DATETIME,
  transaction_file_detail_id NUMERIC(29),
  avi_handshake FLOAT64,
  avi_tag_status STRING,
  veh_speed NUMERIC(31, 2),
  deleted INT64,
  last_update_date DATETIME
)
;
