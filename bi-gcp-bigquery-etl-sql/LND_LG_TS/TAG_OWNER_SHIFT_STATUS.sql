-- Translation time: 2024-06-04T08:03:02.538216Z
-- Translation job ID: 2ee163b6-d1ed-4585-9295-ffd9f05ba970
-- Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_LG_TS/Tables/TAG_OWNER_SHIFT_STATUS.sql
-- Translated from: SqlServer
-- Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_LG_TS.Tag_Owner_Shift_Status
(
  shift_status STRING NOT NULL,
  shift_status_descr STRING NOT NULL,
  shift_status_order INT64,
  is_active STRING NOT NULL,
  last_update_date DATETIME,
  last_update_type STRING
)
;
