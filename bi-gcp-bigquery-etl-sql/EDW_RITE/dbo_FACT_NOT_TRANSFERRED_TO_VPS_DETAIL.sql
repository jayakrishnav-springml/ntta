## Translation time: 2024-03-21T20:56:06.764423Z
## Translation job ID: e212c5d3-a7fa-4886-93b1-cb3be341e70a
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/EDW_RITE/Tables/dbo_FACT_NOT_TRANSFERRED_TO_VPS_DETAIL.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_RITE.Fact_Not_Transferred_To_Vps_Detail
(
  day_id INT64,
  month_id INT64,
  lane_id INT64,
  lane_abbrev STRING NOT NULL,
  lane_viol_id NUMERIC(29) NOT NULL,
  viol_date DATETIME NOT NULL,
  vcly_id INT64 NOT NULL,
  vehicle_class INT64,
  axle_count INT64,
  lane_viol_status STRING,
  lane_viol_status_descr STRING,
  review_status STRING,
  review_status_abbrev STRING NOT NULL,
  status_descr STRING,
  rev_status_descr STRING,
  business_type STRING NOT NULL,
  viol_reject_type STRING,
  viol_reject_type_descr STRING,
  viol_created STRING,
  agency_id NUMERIC(29),
  tag_id STRING,
  tt_id INT64,
  tag_status NUMERIC(29),
  vehicle_speed NUMERIC(29),
  license_plate_id INT64,
  lic_plate_nbr STRING,
  lic_plate_state STRING,
  review_date DATETIME,
  toll_due NUMERIC(31, 2),
  toll_paid NUMERIC(31, 2)
)
CLUSTER BY lane_viol_id;
