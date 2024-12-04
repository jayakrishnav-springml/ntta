-- Translation time: 2024-06-04T08:03:02.538216Z
-- Translation job ID: 2ee163b6-d1ed-4585-9295-ffd9f05ba970
-- Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_LG_TS/Tables/TAG_OWNER_VEHICLE_CLASS_CORRECTION_LIST.sql
-- Translated from: SqlServer
-- Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_LG_TS.Tag_Owner_Vehicle_Class_Correction_List
(
  vehicle_class_correction_id NUMERIC(29) NOT NULL,
  tag_id STRING,
  license_plate_number STRING,
  license_plate_state STRING,
  vehicle_class STRING NOT NULL,
  created_by STRING NOT NULL,
  date_created DATETIME NOT NULL,
  date_expired DATETIME,
  modified_by STRING,
  date_modified DATETIME,
  last_update_date DATETIME,
  last_update_type STRING
)
;
