## Translation time: 2024-03-21T20:56:06.764423Z
## Translation job ID: e212c5d3-a7fa-4886-93b1-cb3be341e70a
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/EDW_RITE/Tables/dbo_NTTA_TOLL_LOCATIONS.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_RITE.Ntta_Toll_Locations
(
  objectid INT64,
  from_statiion BIGNUMERIC(50, 12),
  corridor STRING,
  roadway_name STRING,
  roadway_type STRING,
  roadway_description STRING,
  name STRING,
  rite_name STRING,
  type STRING,
  x_coord BIGNUMERIC(50, 12),
  y_coord BIGNUMERIC(50, 12)
)
;
