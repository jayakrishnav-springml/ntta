## Translation time: 2024-03-04T06:41:57.683170Z
## Translation job ID: 00dc6676-2c12-444a-b02a-71c7788bdc89
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/EDW_TRIPS/Tables/Ref_Plaza_Mileage.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_TRIPS_SUPPORT.Plaza_Mileage
(
  plazaid NUMERIC(29) NOT NULL,
  lanedirection STRING,
  mileage NUMERIC(31, 2)
)
cluster by plazaid
;