## Translation time: 2024-03-04T06:41:57.683170Z
## Translation job ID: 00dc6676-2c12-444a-b02a-71c7788bdc89
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/EDW_TRIPS/Tables/Ref_Plaza_County_XREF.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_TRIPS_SUPPORT.Plaza_County_XREF
(
  plazaid INT64 NOT NULL,
  plazaabbrev STRING NOT NULL,
  lanedirection STRING,
  facilityid NUMERIC(29) NOT NULL,
  facilityabbrev STRING NOT NULL,
  subagencyabbrev STRING NOT NULL,
  agencyabbrev STRING NOT NULL,
  county STRING NOT NULL
)
cluster by plazaid
;