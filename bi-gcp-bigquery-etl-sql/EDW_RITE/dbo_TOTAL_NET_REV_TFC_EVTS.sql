## Translation time: 2024-03-21T20:56:06.764423Z
## Translation job ID: e212c5d3-a7fa-4886-93b1-cb3be341e70a
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/EDW_RITE/Tables/dbo_TOTAL_NET_REV_TFC_EVTS.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_RITE.Total_Net_Rev_Tfc_Evts
(
  atd_id NUMERIC(29),
  opnm_opnm_id NUMERIC(29) NOT NULL,
  pmty_pmty_id NUMERIC(29) NOT NULL,
  vcly_vcly_id NUMERIC(29) NOT NULL,
  lane_lane_id NUMERIC(29),
  tart_tart_id NUMERIC(29),
  date_time DATETIME NOT NULL,
  local_time DATETIME,
  ear_rev NUMERIC(31, 2),
  exp_rev NUMERIC(31, 2),
  act_rev NUMERIC(31, 2),
  avc_class NUMERIC(29),
  ind_class NUMERIC(29),
  rev_axle_ct NUMERIC(29),
  att_class NUMERIC(29),
  fwd_axle_ct NUMERIC(29),
  exit_loop_cts NUMERIC(29),
  att_fare NUMERIC(31, 2),
  pre_class NUMERIC(29),
  misclass_ct INT64 NOT NULL,
  sign_flg INT64 NOT NULL,
  adj_status STRING NOT NULL,
  txid_id NUMERIC(29),
  ves_serial_no NUMERIC(29),
  ves_date_time DATETIME,
  ves_date_time_local DATETIME,
  transaction_file_detail_id NUMERIC(29),
  avi_handshake FLOAT64,
  avi_tag_status STRING,
  veh_speed NUMERIC(31, 2),
  deleted INT64,
  last_update_date DATETIME
)

;
