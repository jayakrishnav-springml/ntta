## Translation time: 2024-03-04T06:41:57.683170Z
## Translation job ID: 00dc6676-2c12-444a-b02a-71c7788bdc89
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/EDW_TRIPS/Tables/Stage_IPS_Image_Review_Results.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_TRIPS_STAGE_APS.IPS_Image_Review_Results
(
  imagereviewresultid INT64 NOT NULL,
  ipstransactionid INT64,
  tptripid INT64,
  ismanuallyreviewed INT64,
  timestamp DATETIME NOT NULL,
  irr_laneid INT64,
  irr_facilitycode STRING NOT NULL,
  irr_plazacode STRING NOT NULL,
  irr_lanecode INT64 NOT NULL,
  vesserialnumber INT64 NOT NULL,
  plateregistration STRING,
  platejurisdiction STRING,
  reasoncode STRING,
  disposition INT64 NOT NULL,
  createduser STRING NOT NULL,
  createddate DATETIME NOT NULL,
  updateduser STRING NOT NULL,
  updateddate DATETIME NOT NULL,
  edw_updatedate DATETIME
)CLUSTER BY tptripid
;