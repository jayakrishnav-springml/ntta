-- Translation time: 2024-06-04T08:04:57.852399Z
-- Translation job ID: d189ef38-1420-4658-96a7-29624b482bd7
-- Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_LG_VPS/Tables/VP_OWNER_VPS_EXCUSALS.sql
-- Translated from: SqlServer
-- Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_LG_VPS.Vp_Owner_Vps_Excusals
(
  transaction_type STRING NOT NULL,
  status_date DATETIME NOT NULL,
  viol_date DATETIME,
  violation_id FLOAT64,
  lane_viol_id NUMERIC(29),
  lic_plate_info STRING,
  excused_by_name STRING,
  excused_reas_descr STRING,
  toll_amount NUMERIC(33, 4) NOT NULL,
  excused_toll_amount NUMERIC(33, 4) NOT NULL,
  paid_amount NUMERIC(33, 4) NOT NULL,
  violator_id NUMERIC(29),
  writeoff_flag STRING,
  lane_id NUMERIC(29),
  last_update_type STRING NOT NULL,
  last_update_date DATETIME NOT NULL
)
;
