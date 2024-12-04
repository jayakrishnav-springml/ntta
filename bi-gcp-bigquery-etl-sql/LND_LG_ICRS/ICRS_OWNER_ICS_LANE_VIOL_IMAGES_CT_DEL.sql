-- Translation time: 2024-06-04T07:59:17.388387Z
-- Translation job ID: 5118bff3-1545-4bd3-96b6-65be13aded87
-- Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_LG_ICRS/Tables/ICRS_OWNER_ICS_LANE_VIOL_IMAGES_CT_DEL.sql
-- Translated from: SqlServer
-- Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_LG_ICRS.Icrs_Owner_Ics_Lane_Viol_Images_Ct_Del
(
  lane_viol_id NUMERIC(29) NOT NULL,
  viol_image_seq INT64 NOT NULL,
  image_name STRING,
  image_location STRING,
  image_status STRING,
  is_selected STRING,
  is_roi STRING,
  archive_status STRING,
  archive_loc STRING,
  ff_id NUMERIC(29),
  is_front STRING,
  dac_ocr_plate_nbr STRING,
  dac_ocr_plate_state STRING,
  dac_ocr_plate_confid BIGNUMERIC(48, 10),
  insert_datetime DATETIME NOT NULL
)
;
