## Translation time: 2024-03-21T20:56:06.764423Z
## Translation job ID: e212c5d3-a7fa-4886-93b1-cb3be341e70a
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/EDW_RITE/Tables/dbo_TA_TXN_RITE_DATAS.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_RITE.Ta_Txn_Rite_Datas
(
  partition_values INT64,
  veh_speed NUMERIC(31, 2),
  event_ind STRING,
  logon_time DATETIME,
  active_vlt_ch STRING,
  turd_id NUMERIC(29) NOT NULL,
  tart_tart_id NUMERIC(29) NOT NULL,
  logon_means STRING,
  empl_id NUMERIC(29),
  vplt_id INT64,
  rev_lane_ind STRING,
  isf_serial_no NUMERIC(29),
  ves_serial_no NUMERIC(29),
  ves_date_time DATETIME,
  ves_date_time_local DATETIME,
  standby_mode_status INT64,
  acm_status NUMERIC(29),
  avi_status INT64,
  veh_avc_status INT64,
  treadle_avc_status INT64,
  ves_trigger_status INT64,
  ves_status INT64,
  att_term_status INT64,
  fac_srvr_avi_status INT64,
  fac_srvr_upload_txns INT64,
  ups_status INT64,
  digital_io_status INT64,
  nonrev_empl_id NUMERIC(29),
  ln_straddle_ind STRING,
  att_class_entered STRING,
  vio_image_req STRING,
  coin_rejected STRING,
  last_update_type STRING NOT NULL,
  last_update_date DATETIME NOT NULL
)
;
