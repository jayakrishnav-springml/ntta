## Translation time: 2024-03-21T20:56:06.764423Z
## Translation job ID: e212c5d3-a7fa-4886-93b1-cb3be341e70a
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/EDW_RITE/Tables/dbo_DIM_LANE.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_RITE.Dim_Lane
(
  lane_id NUMERIC(29) NOT NULL,
  lane_abbrev STRING NOT NULL,
  lane_name STRING,
  lane_direction STRING,
  plaza_id NUMERIC(29) NOT NULL,
  plaza_abbrev STRING NOT NULL,
  plaza_name STRING NOT NULL,
  plaza_latitude BIGNUMERIC(50, 12),
  plaza_longitude BIGNUMERIC(50, 12),
  zip_code INT64,
  county STRING,
  sub_facility_abbrev STRING NOT NULL,
  facility_id NUMERIC(29) NOT NULL,
  facility_abbrev STRING NOT NULL,
  facility_name STRING NOT NULL,
  facility_bitmask_id INT64 NOT NULL,
  sub_agency_abbrev STRING NOT NULL,
  agency_id NUMERIC(29) NOT NULL,
  agency_abbrev STRING NOT NULL,
  agency_name STRING NOT NULL,
  agency_is_iop STRING,
  lany_id NUMERIC(29),
  mileage NUMERIC(31, 2),
  plaza_sort_order INT64,
  active INT64 NOT NULL,
  last_update_date DATETIME NOT NULL
)
cluster by lane_id
;
