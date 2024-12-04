-- Translation time: 2024-06-04T07:57:18.317878Z
-- Translation job ID: b2abff43-eccf-406a-aa5d-053048797d89
-- Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_LG_HOST/Tables/TXNOWNER_CURR_TOLL_REGIONAL_RATE.sql
-- Translated from: SqlServer
-- Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_LG_HOST.TxnOwner_Curr_Toll_Regional_Rate
(
  plaz_id NUMERIC(29) NOT NULL,
  vehicle_class FLOAT64,
  toll_seq FLOAT64,
  tag_toll NUMERIC(29),
  cash_toll NUMERIC(29),
  toll_start_time DATETIME NOT NULL,
  toll_end_time DATETIME,
  region_iop_toll FLOAT64,
  system_iop_toll FLOAT64,
  last_update_type STRING NOT NULL,
  last_update_date DATETIME NOT NULL
)
cluster by plaz_id
;
