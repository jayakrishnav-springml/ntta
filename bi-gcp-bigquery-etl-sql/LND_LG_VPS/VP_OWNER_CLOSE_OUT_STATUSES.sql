-- Translation time: 2024-06-04T08:04:57.852399Z
-- Translation job ID: d189ef38-1420-4658-96a7-29624b482bd7
-- Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_LG_VPS/Tables/VP_OWNER_CLOSE_OUT_STATUSES.sql
-- Translated from: SqlServer
-- Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_LG_VPS.Vp_Owner_Close_Out_Statuses
(
  close_out_status STRING NOT NULL,
  close_out_status_descr STRING NOT NULL,
  close_out_status_long_descr STRING NOT NULL,
  close_out_status_order INT64 NOT NULL,
  default_value_flag STRING NOT NULL,
  last_update_type STRING,
  last_update_date DATETIME
)
;
