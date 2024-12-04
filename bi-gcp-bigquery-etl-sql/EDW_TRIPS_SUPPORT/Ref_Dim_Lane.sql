## Translation time: 2024-03-04T06:41:57.683170Z
## Translation job ID: 00dc6676-2c12-444a-b02a-71c7788bdc89
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/EDW_TRIPS/Tables/Ref_Dim_Lane.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_TRIPS_SUPPORT.Dim_Lane
(
  laneid NUMERIC(29) NOT NULL,
  laneabbrev STRING NOT NULL,
  lanename STRING,
  lanedirection STRING,
  plazaid NUMERIC(29) NOT NULL,
  plazaabbrev STRING NOT NULL,
  plazaname STRING NOT NULL,
  plazalatitude BIGNUMERIC(50, 12),
  plazalongitude BIGNUMERIC(50, 12),
  zipcode INT64,
  county STRING,
  subfacilityabbrev STRING NOT NULL,
  facilityid NUMERIC(29) NOT NULL,
  facilityabbrev STRING NOT NULL,
  facilityname STRING NOT NULL,
  facilitybitmaskid INT64 NOT NULL,
  subagencyabbrev STRING NOT NULL,
  agencyid NUMERIC(29) NOT NULL,
  agencyabbrev STRING NOT NULL,
  agencyname STRING NOT NULL,
  agencyisiop STRING,
  lanyid NUMERIC(29),
  mileage NUMERIC(31, 2),
  plazasortorder INT64,
  active INT64 NOT NULL,
  lastupdatedate DATETIME NOT NULL
)
cluster by laneid
;