## Translation time: 2024-03-21T20:56:06.764423Z
## Translation job ID: e212c5d3-a7fa-4886-93b1-cb3be341e70a
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/EDW_RITE/Tables/dbo_DIM_FACILITY.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_RITE.Dim_Facility
(
  facility_id NUMERIC(29) NOT NULL,
  facility_abbrev STRING NOT NULL,
  facility_name STRING NOT NULL,
  agency_id NUMERIC(29) NOT NULL,
  agency_abbrev STRING NOT NULL,
  agency_name STRING NOT NULL,
  agency_is_iop STRING NOT NULL,
  facility_bitmask_id INT64 NOT NULL,
  last_update_date DATETIME NOT NULL
)
cluster by facility_id
;
