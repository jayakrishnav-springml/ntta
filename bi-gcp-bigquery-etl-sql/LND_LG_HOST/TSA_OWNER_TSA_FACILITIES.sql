-- Translation time: 2024-06-04T07:57:18.317878Z
-- Translation job ID: b2abff43-eccf-406a-aa5d-053048797d89
-- Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_LG_HOST/Tables/TSA_OWNER_TSA_FACILITIES.sql
-- Translated from: SqlServer
-- Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_LG_HOST.Tsa_Owner_Tsa_Facilities
(
  tsa_facility_id INT64 NOT NULL,
  tsa_facility_code STRING,
  facs_id NUMERIC(29) NOT NULL,
  icd_location_code STRING,
  plaz_id NUMERIC(29),
  is_active STRING,
  created_by STRING,
  date_created DATETIME,
  modified_by STRING,
  date_modified DATETIME,
  subscriber_lane_id STRING,
  lane_id STRING,
  last_update_type STRING NOT NULL,
  last_update_date DATETIME NOT NULL
)
cluster by tsa_facility_id
;
