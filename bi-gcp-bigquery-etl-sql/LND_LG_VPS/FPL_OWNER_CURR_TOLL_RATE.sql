-- Translation time: 2024-06-04T08:04:57.852399Z
-- Translation job ID: d189ef38-1420-4658-96a7-29624b482bd7
-- Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_LG_VPS/Tables/FPL_OWNER_CURR_TOLL_RATE.sql
-- Translated from: SqlServer
-- Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_LG_VPS.Fpl_Owner_Curr_Toll_Rate
(
  plaza_id NUMERIC(29) NOT NULL,
  vehicle_class BIGNUMERIC(48, 10),
  toll_seq BIGNUMERIC(48, 10),
  tag_toll BIGNUMERIC(48, 10),
  cash_toll BIGNUMERIC(48, 10),
  toll_start_time DATETIME NOT NULL,
  toll_end_time DATETIME,
  last_update_date DATETIME,
  last_update_type STRING
)
;
