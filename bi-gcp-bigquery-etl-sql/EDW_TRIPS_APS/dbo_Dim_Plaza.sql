## Translation time: 2024-03-04T06:41:57.683170Z
## Translation job ID: 00dc6676-2c12-444a-b02a-71c7788bdc89
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/EDW_TRIPS/Tables/dbo_Dim_Plaza.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_TRIPS_APS.Dim_Plaza
(
  plazaid INT64 NOT NULL,
  plazacode STRING,
  ips_plazacode STRING,
  plazaname STRING NOT NULL,
  plazalatitude BIGNUMERIC(50, 12) NOT NULL,
  plazalongitude BIGNUMERIC(50, 12) NOT NULL,
  zipcode INT64 NOT NULL,
  county STRING NOT NULL,
  facilityid INT64 NOT NULL,
  facilitycode STRING,
  facilityname STRING,
  ips_facilitycode STRING,
  tsaflag INT64,
  tsafacilityid INT64,
  bitmaskid INT64 NOT NULL,
  subagencyabbrev STRING,
  operationsagency STRING,
  agencyid INT64 NOT NULL,
  agencytype STRING NOT NULL,
  agencyname STRING,
  agencycode STRING NOT NULL,
  agencystartdate DATETIME,
  agencyenddate DATETIME,
  lnd_updateddate DATETIME,
  edw_updateddate TIMESTAMP NOT NULL
)
CLUSTER BY plazaid
;