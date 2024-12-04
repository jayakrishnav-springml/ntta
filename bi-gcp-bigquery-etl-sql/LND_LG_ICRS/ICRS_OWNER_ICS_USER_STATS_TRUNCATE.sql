-- Translation time: 2024-06-04T07:59:17.388387Z
-- Translation job ID: 5118bff3-1545-4bd3-96b6-65be13aded87
-- Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_LG_ICRS/Tables/ICRS_OWNER_ICS_USER_STATS_TRUNCATE.sql
-- Translated from: SqlServer
-- Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_LG_ICRS.Icrs_Owner_Ics_User_Stats_Truncate
(
  stat_id FLOAT64 NOT NULL,
  lane_viol_id NUMERIC(29) NOT NULL,
  reviewed_by STRING,
  elapsed_time FLOAT64,
  save FLOAT64,
  revert FLOAT64,
  image_status FLOAT64,
  lp_number FLOAT64,
  state FLOAT64,
  roi_image FLOAT64,
  primary_image FLOAT64,
  secondary_image FLOAT64,
  switch_primary_image FLOAT64,
  created_by STRING,
  date_created DATETIME,
  modified_by STRING,
  date_modified DATETIME,
  reviewed_date DATETIME,
  back FLOAT64,
  image_type STRING,
  change_type STRING,
  primary_img_changed INT64,
  secondary_img_changed INT64,
  front_roi_changed INT64,
  back_roi_changed INT64,
  accessurl STRING,
  last_update_type STRING NOT NULL,
  last_update_date DATETIME NOT NULL
)
;
