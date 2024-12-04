## Translation time: 2024-03-04T06:41:57.683170Z
## Translation job ID: 00dc6676-2c12-444a-b02a-71c7788bdc89
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/EDW_TRIPS/Tables/Ref_NTTA_Toll_Locations.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_TRIPS_SUPPORT.NTTA_Toll_Locations
(
  objectid INT64,
  fromstatiion BIGNUMERIC(50, 12),
  corridor STRING,
  roadwayname STRING,
  roadwaytype STRING,
  roadwaydescription STRING,
  name STRING,
  ritename STRING,
  type STRING,
  xcoord BIGNUMERIC(50, 12),
  ycoord BIGNUMERIC(50, 12)
)
;