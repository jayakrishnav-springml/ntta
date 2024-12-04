## Translation time: 2024-03-04T06:44:00.523569Z
## Translation job ID: a86d938d-fa65-424d-bf4e-0008985e1778
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_TBOS/Tables/TollPlus_TP_Image_Review_Results.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_TBOS.TollPlus_TP_Image_Review_Results
(
  imagereviewresultid INT64 NOT NULL,
  sourcetransactionid INT64,
  ipstransactionid INT64,
  facilitycode STRING NOT NULL,
  plazacode STRING NOT NULL,
  lanecode INT64 NOT NULL,
  timestamp DATETIME NOT NULL,
  vesserialnumber INT64 NOT NULL,
  disposition INT64 NOT NULL,
  reasoncode STRING,
  ismanuallyreviewed INT64,
  platetype STRING,
  plateregistration STRING,
  platejurisdiction STRING,
  platejurisdictioncountry STRING,
  sourcelanvilationid INT64,
  sourcevilationid INT64,
  imagecodeoff INT64,
  imagereviewcount INT64,
  createduser STRING NOT NULL,
  createddate DATETIME NOT NULL,
  updateduser STRING NOT NULL,
  updateddate DATETIME NOT NULL,
  lnd_updatedate DATETIME,
  lnd_updatetype STRING,
  src_changedate DATETIME
)
cluster by ImageReviewResultID
;