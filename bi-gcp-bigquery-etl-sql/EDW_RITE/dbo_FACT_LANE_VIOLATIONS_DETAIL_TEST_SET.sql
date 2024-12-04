## Translation time: 2024-03-21T20:56:06.764423Z
## Translation job ID: e212c5d3-a7fa-4886-93b1-cb3be341e70a
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/EDW_RITE/Tables/dbo_FACT_LANE_VIOLATIONS_DETAIL_TEST_SET.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_RITE.Fact_Lane_Violations_Detail_Test_Set
(
  day_id INT64,
  lane_id NUMERIC(29),
  lane_abbrev STRING,
  lane_viol_id NUMERIC(29) NOT NULL,
  violation_id NUMERIC(29) NOT NULL,
  viol_date DATETIME,
  vehicle_class INT64,
  vcly_id NUMERIC(29) NOT NULL,
  axle_count INT64,
  lane_viol_status STRING NOT NULL,
  lane_viol_status_descr STRING,
  review_status STRING NOT NULL,
  review_status_abbrev STRING,
  status_descr STRING,
  rev_status_descr STRING,
  business_type STRING NOT NULL,
  viol_reject_type STRING NOT NULL,
  viol_reject_type_descr STRING,
  viol_created STRING,
  agency_id INT64,
  tag_id STRING,
  tag_status INT64,
  vehicle_speed INT64,
  lic_plate_nbr STRING,
  lic_plate_state STRING,
  license_plate_id INT64,
  review_date DATETIME,
  toll_due NUMERIC(31, 2),
  toll_paid NUMERIC(31, 2),
  violation_code INT64,
  reviewed_by STRING,
  transaction_file_detail_id NUMERIC(29) NOT NULL,
  last_update_type STRING,
  last_update_date DATETIME
)
;
