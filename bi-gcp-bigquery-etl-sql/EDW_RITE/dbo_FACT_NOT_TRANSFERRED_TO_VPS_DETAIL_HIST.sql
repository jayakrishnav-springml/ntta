## Translation time: 2024-03-21T20:56:06.764423Z
## Translation job ID: e212c5d3-a7fa-4886-93b1-cb3be341e70a
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/EDW_RITE/Tables/dbo_FACT_NOT_TRANSFERRED_TO_VPS_DETAIL_HIST.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_RITE.Fact_Not_Transferred_To_Vps_Detail_Hist
(
  partition_date DATE,
  day_id STRING,
  lane_id NUMERIC(29) NOT NULL,
  lane_abbrev STRING NOT NULL,
  lane_viol_id NUMERIC(29) NOT NULL,
  viol_date DATETIME NOT NULL,
  vcly_id NUMERIC(29) NOT NULL,
  vehicle_class NUMERIC(29),
  axle_count NUMERIC(29),
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
  tag_status NUMERIC(29),
  vehicle_speed NUMERIC(29),
  lic_plate_nbr STRING,
  lic_plate_state STRING,
  review_date DATETIME,
  toll_due NUMERIC(31, 2),
  toll_paid NUMERIC(31, 2)
)
;
