## Translation time: 2024-03-21T20:56:06.764423Z
## Translation job ID: e212c5d3-a7fa-4886-93b1-cb3be341e70a
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/EDW_RITE/Tables/dbo_DIM_PLAZA.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_RITE.Dim_Plaza
(
  plaza_id NUMERIC(29) NOT NULL,
  plaza_abbrev STRING NOT NULL,
  plaza_name STRING NOT NULL,
  plaza_latitude BIGNUMERIC(50, 12),
  plaza_longitude BIGNUMERIC(50, 12),
  zip_code INT64 NOT NULL,
  county STRING NOT NULL,
  facility_id NUMERIC(29) NOT NULL,
  facility_abbrev STRING NOT NULL,
  facility_name STRING NOT NULL,
  agency_id NUMERIC(29) NOT NULL,
  agency_abbrev STRING NOT NULL,
  agency_name STRING,
  agency_is_iop STRING,
  last_update_date DATETIME
)
cluster by plaza_id
;
