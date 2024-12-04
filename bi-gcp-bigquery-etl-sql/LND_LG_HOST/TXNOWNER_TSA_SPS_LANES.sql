-- Translation time: 2024-06-04T07:57:18.317878Z
-- Translation job ID: b2abff43-eccf-406a-aa5d-053048797d89
-- Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_LG_HOST/Tables/TXNOWNER_TSA_SPS_LANES.sql
-- Translated from: SqlServer
-- Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_LG_HOST.TxnOwner_Tsa_Sps_Lanes
(
  lane_id NUMERIC(29),
  name STRING,
  regional_toll_amt_flag STRING,
  region STRING,
  last_update_date DATETIME,
  last_update_type STRING
)
;
