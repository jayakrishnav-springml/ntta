-- Translation time: 2024-06-04T07:57:18.317878Z
-- Translation job ID: b2abff43-eccf-406a-aa5d-053048797d89
-- Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_LG_HOST/Tables/HAS_OWNER_HA_AVI_TXNSES_CT_DEL.sql
-- Translated from: SqlServer
-- Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_LG_HOST.Has_Owner_Ha_Avi_Txnses_Ct_Del
(
  earned_class INT64 NOT NULL,
  earned_revenue INT64 NOT NULL,
  posted_class INT64 NOT NULL,
  posted_revenue INT64 NOT NULL,
  bus_day DATETIME NOT NULL,
  hat_id NUMERIC(29) NOT NULL,
  lane_lane_id NUMERIC(29) NOT NULL,
  txn_count INT64,
  start_time DATETIME,
  end_time DATETIME,
  summ_time DATETIME,
  reason_code STRING,
  hia_agcy_id NUMERIC(29),
  det_link_rev NUMERIC(29),
  det_link_var NUMERIC(29),
  posted_day DATETIME,
  insert_datetime DATETIME NOT NULL
)
;
