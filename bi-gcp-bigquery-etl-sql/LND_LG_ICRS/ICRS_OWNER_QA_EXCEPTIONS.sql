-- Translation time: 2024-06-04T07:59:17.388387Z
-- Translation job ID: 5118bff3-1545-4bd3-96b6-65be13aded87
-- Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_LG_ICRS/Tables/ICRS_OWNER_QA_EXCEPTIONS.sql
-- Translated from: SqlServer
-- Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_LG_ICRS.Icrs_Owner_Qa_Exceptions
(
  lane_viol_id NUMERIC(29) NOT NULL,
  violation_id BIGNUMERIC(48, 10) NOT NULL,
  status STRING,
  modified_date DATETIME,
  modified_by STRING,
  created_date DATETIME,
  created_by STRING,
  lic_plate_nbr STRING,
  lic_plate_state STRING,
  image_loc_path STRING,
  roiimage_loc_path STRING,
  last_update_date DATETIME,
  last_update_type STRING
)
;
