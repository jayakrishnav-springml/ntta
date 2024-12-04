-- Translation time: 2024-06-04T07:57:18.317878Z
-- Translation job ID: b2abff43-eccf-406a-aa5d-053048797d89
-- Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_LG_HOST/Tables/TXNOWNER_AU_ALL_PARTIAL_SHIFTS.sql
-- Translated from: SqlServer
-- Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_LG_HOST.TxnOwner_Au_All_Partial_Shifts
(
  aps_id NUMERIC(29) NOT NULL,
  start_time DATETIME NOT NULL,
  stop_time DATETIME NOT NULL,
  att_bus_day DATETIME,
  avi_bus_day DATETIME,
  vlt_bus_day DATETIME,
  category STRING NOT NULL,
  aps_from_aps_id NUMERIC(29),
  vplt_vplt_id NUMERIC(29),
  empl_empl_id NUMERIC(29),
  lane_lane_id NUMERIC(29) NOT NULL,
  aast1_aast1_id NUMERIC(29) NOT NULL,
  lc_flg STRING NOT NULL,
  creation_date DATETIME NOT NULL,
  created_by STRING NOT NULL,
  updated_date DATETIME NOT NULL,
  updated_by STRING NOT NULL,
  status STRING,
  last_update_type STRING NOT NULL,
  last_update_date DATETIME NOT NULL
)
cluster by aps_id
;
