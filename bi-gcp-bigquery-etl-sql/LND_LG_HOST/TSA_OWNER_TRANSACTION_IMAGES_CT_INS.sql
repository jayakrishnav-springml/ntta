-- Translation time: 2024-06-04T07:57:18.317878Z
-- Translation job ID: b2abff43-eccf-406a-aa5d-053048797d89
-- Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_LG_HOST/Tables/TSA_OWNER_TRANSACTION_IMAGES_CT_INS.sql
-- Translated from: SqlServer
-- Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_LG_HOST.Tsa_Owner_Transaction_Images_Ct_Ins
(
  transaction_image_id NUMERIC(29),
  transaction_file_detail_id NUMERIC(29),
  image_file_name STRING,
  image_location_type STRING,
  image_facing_code STRING,
  image_sequence INT64,
  license_plate_state STRING,
  license_plate_state_conf INT64,
  license_plate_country STRING,
  license_plate_country_conf INT64,
  license_plate_value STRING,
  license_plate_value_conf INT64,
  license_plate_type STRING,
  license_plate_type_conf INT64,
  ocr_engine_type STRING,
  license_plate_overall_conf INT64,
  roi_upper_left_x INT64,
  roi_upper_left_y INT64,
  roi_lower_right_x INT64,
  roi_lower_right_y INT64,
  license_plate_status STRING,
  dac_ocr_plate_state STRING,
  dac_ocr_plate_value STRING,
  dac_ocr_roi_x1 INT64,
  dac_ocr_roi_y1 INT64,
  dac_ocr_roi_x2 INT64,
  dac_ocr_roi_y2 INT64,
  created_by STRING,
  date_created DATETIME,
  modified_by STRING,
  date_modified DATETIME,
  image_location STRING,
  roi_file_name STRING,
  ocr_status STRING,
  failure_reason STRING,
  dac_ocr_lic_plate_overall_conf INT64,
  ocr_server STRING,
  insert_datetime DATETIME NOT NULL
)
;
