-- Translation time: 2024-06-04T07:59:17.388387Z
-- Translation job ID: 5118bff3-1545-4bd3-96b6-65be13aded87
-- Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_LG_ICRS/Tables/ICRS_OWNER_ICS_LANE_VIOLATIONS.sql
-- Translated from: SqlServer
-- Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_LG_ICRS.Icrs_Owner_Ics_Lane_Violations
(
  lane_viol_id NUMERIC(29) NOT NULL,
  lane_viol_status STRING,
  lc_plaza_nbr STRING,
  lc_lane_nbr STRING,
  viol_date DATETIME NOT NULL,
  time_nbr NUMERIC(29),
  sequence_nbr NUMERIC(29),
  lane_mode NUMERIC(29),
  employee_id NUMERIC(29),
  vehicle_class NUMERIC(29),
  axle_count NUMERIC(29),
  violation_code NUMERIC(29),
  unusual_code NUMERIC(29),
  toll_due NUMERIC(31, 2),
  toll_paid NUMERIC(31, 2),
  agency_id NUMERIC(29),
  tag_id STRING,
  tag_status NUMERIC(29),
  vehicle_speed NUMERIC(29),
  consec_prev_viol NUMERIC(29),
  consec_follow_viol NUMERIC(29),
  poss_false_trigger STRING,
  device_status NUMERIC(29),
  fail_reason NUMERIC(29),
  lic_plate_nbr STRING,
  ocr_nbr_confid NUMERIC(29),
  lic_plate_state STRING,
  ocr_state_confid NUMERIC(29),
  image_name STRING,
  roi_image_name STRING,
  image_loc STRING,
  image_archive_loc STRING,
  ocr_confid_cutoff NUMERIC(29),
  state_confid_cutoff NUMERIC(29),
  reviewed_by STRING,
  pre_audit_result STRING,
  audit_result STRING,
  created_date DATETIME NOT NULL,
  modified_date DATETIME,
  lane_abbrev STRING NOT NULL,
  ves_name STRING,
  sequence_nbr1 NUMERIC(29),
  lane_controller_type STRING,
  review_status STRING,
  viol_reject_type STRING,
  review_date DATETIME,
  status_date DATETIME,
  viol_created STRING,
  review_user_id NUMERIC(29),
  lc_facility_code STRING,
  plaza_code STRING,
  lane_code STRING,
  lic_plate_nbr_2 STRING,
  host_transaction_id NUMERIC(29),
  lane_id NUMERIC(29) NOT NULL,
  ocr_plate_nbr STRING,
  ocr_plate_state STRING,
  mark_for_delete_user_id NUMERIC(29),
  mark_for_delete_date DATETIME,
  delete_date DATETIME,
  ff_id NUMERIC(29),
  review_time_sec FLOAT64,
  dac_ocr_plate_nbr STRING,
  dac_ocr_plate_state STRING,
  dac_ocr_plate_confid FLOAT64,
  dac_ocr_modified_date DATETIME,
  source_server STRING,
  forward_axles NUMERIC(29),
  reverse_axles NUMERIC(29),
  lic_plate_type STRING,
  ocr_type_results STRING,
  ocr_type_confid NUMERIC(29),
  plate_audit_status STRING,
  plate_audit_tag_id STRING,
  plate_audit_agency_id STRING,
  certified STRING,
  wavelets_purged_yn STRING,
  vtoll_disposition STRING,
  ocr_plate_nbr_2nd STRING,
  ocr_plate_state_2nd STRING,
  ocr_nbr_confid_2nd NUMERIC(29),
  ocr_state_confid_2nd NUMERIC(29),
  image_name_2nd STRING,
  roi_image_name_2nd STRING,
  image_loc_2nd STRING,
  picked_image_seq NUMERIC(29),
  picked_roi_seq NUMERIC(29),
  ftd_id NUMERIC(29),
  ves_name_2nd STRING,
  ff_id_2nd NUMERIC(29),
  sequence_nbr1_2nd NUMERIC(29),
  status STRING,
  review_vehicle_class NUMERIC(29),
  primary_side STRING,
  host_close_date DATETIME,
  facs_id NUMERIC(29),
  plaz_id NUMERIC(29),
  image_type STRING,
  picked_image_seq_2nd NUMERIC(29),
  excused_event_id NUMERIC(29),
  sent_for_rereview STRING,
  qa_status STRING,
  re_reviewed_by STRING,
  re_reviewed_date DATETIME,
  last_qa_by STRING,
  last_qa_date DATETIME,
  camera_lic_plate_nbr STRING,
  camera_lic_plate_state STRING,
  camera_lic_plate_confid NUMERIC(29),
  accessurl STRING,
  transaction_file_detail_id NUMERIC(29),
  subscriber_id STRING,
  last_update_type STRING,
  last_update_date DATETIME
)
CLUSTER BY lane_viol_id
;
