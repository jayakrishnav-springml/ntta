## Translation time: 2024-03-04T06:41:57.683170Z
## Translation job ID: 00dc6676-2c12-444a-b02a-71c7788bdc89
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/EDW_TRIPS/Tables/dbo_Dim_Lane.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_TRIPS_APS.Dim_Lane
(
  laneid INT64 NOT NULL,
  lanecategoryid INT64 NOT NULL,
  lanecode STRING NOT NULL,
  lanenumber STRING,
  lanename STRING NOT NULL,
  lanedirection STRING,
  plazadirectionid STRING,
  lanelatitude BIGNUMERIC(50, 12),
  lanelongitude BIGNUMERIC(50, 12),
  lanezipcode INT64,
  lanecountyname STRING,
  mileage NUMERIC(31, 2) NOT NULL,
  exitlanecode STRING NOT NULL,
  plazaid INT64,
  plazacode STRING,
  ips_plazacode STRING,
  plazaname STRING,
  plazalatitude BIGNUMERIC(50, 12),
  plazalongitude BIGNUMERIC(50, 12),
  plazazipcode INT64,
  plazacountyname STRING,
  plazasortorder INT64,
  active INT64 NOT NULL,
  facilityid INT64,
  facilitycode STRING,
  facilityname STRING,
  ips_facilitycode STRING,
  tsaflag INT64,
  tsafacilityid INT64,
  bitmaskid INT64,
  subagencyabbrev STRING,
  operationsagency STRING,
  agencyid INT64,
  agencytype STRING,
  agencyname STRING,
  agencycode STRING,
  agencystartdate DATETIME,
  agencyenddate DATETIME,
  updateddate DATETIME NOT NULL,
  edw_updateddate DATETIME NOT NULL
)
cluster by laneid
;
