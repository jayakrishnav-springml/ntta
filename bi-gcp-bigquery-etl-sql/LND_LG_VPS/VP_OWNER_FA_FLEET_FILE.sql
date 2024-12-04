-- Translation time: 2024-06-04T08:04:57.852399Z
-- Translation job ID: d189ef38-1420-4658-96a7-29624b482bd7
-- Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_LG_VPS/Tables/VP_OWNER_FA_FLEET_FILE.sql
-- Translated from: SqlServer
-- Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_LG_VPS.Vp_Owner_Fa_Fleet_File
(
  fleet_file_id NUMERIC(29) NOT NULL,
  agency_id NUMERIC(29) NOT NULL,
  lic_plate_nbr STRING NOT NULL,
  lic_plate_state STRING NOT NULL,
  purchase_date DATETIME NOT NULL,
  sell_date DATETIME,
  vin STRING NOT NULL,
  vehicle_status STRING NOT NULL,
  vehicle_information STRING,
  date_created DATETIME NOT NULL,
  date_modified DATETIME NOT NULL,
  modified_by STRING NOT NULL,
  created_by STRING NOT NULL,
  plate_type_code STRING,
  file_sequence_number NUMERIC(29),
  record_number INT64,
  last_update_date DATETIME,
  last_update_type STRING
)
;