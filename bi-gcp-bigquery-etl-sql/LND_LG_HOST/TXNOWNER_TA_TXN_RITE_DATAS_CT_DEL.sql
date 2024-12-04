-- Translation time: 2024-06-04T07:57:18.317878Z
-- Translation job ID: b2abff43-eccf-406a-aa5d-053048797d89
-- Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_LG_HOST/Tables/TXNOWNER_TA_TXN_RITE_DATAS_CT_DEL.sql
-- Translated from: SqlServer
-- Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_LG_HOST.TxnOwner_Ta_Txn_Rite_Datas_Ct_Del
(
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
  insert_datetime DATETIME NOT NULL
)
;
