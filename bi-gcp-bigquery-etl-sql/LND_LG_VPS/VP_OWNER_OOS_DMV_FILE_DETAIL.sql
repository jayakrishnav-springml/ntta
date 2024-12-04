-- Translation time: 2024-06-04T08:04:57.852399Z
-- Translation job ID: d189ef38-1420-4658-96a7-29624b482bd7
-- Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_LG_VPS/Tables/VP_OWNER_OOS_DMV_FILE_DETAIL.sql
-- Translated from: SqlServer
-- Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_LG_VPS.Vp_Owner_Oos_Dmv_File_Detail
(
  id NUMERIC(29) NOT NULL,
  file_id NUMERIC(29) NOT NULL,
  violator_id NUMERIC(29),
  lic_plate_nbr STRING,
  lic_plate_state STRING,
  violator_fname STRING,
  violators_lname STRING,
  driver_lic_nbr STRING,
  driver_lic_state STRING,
  start_date STRING,
  end_date STRING,
  vehicle_make STRING,
  vehicle_model STRING,
  vehicle_year STRING,
  vehicle_body STRING,
  vehicle_color STRING,
  vehicle_vin STRING,
  record_source STRING,
  title_docno STRING,
  address_street1 STRING,
  address_street2 STRING,
  address_city STRING,
  address_state STRING,
  address_zipcode STRING,
  address_plus4 STRING,
  exception_reason STRING,
  send_email STRING,
  date_created DATETIME,
  created_by STRING,
  date_modified DATETIME,
  modified_by STRING,
  last_update_date DATETIME,
  last_update_type STRING
)
;
