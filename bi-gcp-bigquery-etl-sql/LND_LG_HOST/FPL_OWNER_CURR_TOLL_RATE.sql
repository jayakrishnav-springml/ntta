-- Translation time: 2024-06-04T07:57:18.317878Z
-- Translation job ID: b2abff43-eccf-406a-aa5d-053048797d89
-- Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_LG_HOST/Tables/FPL_OWNER_CURR_TOLL_RATE.sql
-- Translated from: SqlServer
-- Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_LG_HOST.Fpl_Owner_Curr_Toll_Rate
(
  plaza_id NUMERIC(29) NOT NULL,
  vehicle_class FLOAT64,
  toll_seq FLOAT64,
  tag_toll FLOAT64,
  cash_toll FLOAT64,
  toll_start_time DATETIME NOT NULL,
  toll_end_time DATETIME,
  last_update_type STRING NOT NULL,
  last_update_date DATETIME NOT NULL
)
cluster by plaza_id
;
