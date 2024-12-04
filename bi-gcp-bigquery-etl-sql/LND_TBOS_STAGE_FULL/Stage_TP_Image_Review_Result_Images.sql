## Translation time: 2024-03-04T06:44:00.523569Z
## Translation job ID: a86d938d-fa65-424d-bf4e-0008985e1778
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_TBOS/Tables/Stage_TP_Image_Review_Result_Images.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_TBOS_STAGE_FULL.TollPlus_TP_Image_Review_Result_Images
(
  imagereviewresultimageid INT64 NOT NULL,
  imagereviewresultid INT64 NOT NULL,
  imagefilename STRING,
  imagelocation STRING,
  imagetype STRING,
  imageconfidance INT64,
  imagepriority STRING,
  roiimagename STRING,
  roiimagepath STRING,
  vehiclenumber STRING,
  vehiclecountry STRING,
  vehiclestate STRING,
  platetype STRING,
  isdownloadrequired INT64,
  isocrrequired INT64,
  ismirrequired INT64,
  isvalid INT64,
  platestateconfidencelevel INT64,
  platecountryconfidencelevel INT64,
  platevalueconfidencelevel INT64,
  platetypeconfidencelevel INT64,
  plateoverallconfidencelevel INT64,
  filepathconfigurationid INT64,
  sourceimageseq INT64,
  createduser STRING NOT NULL,
  createddate DATETIME NOT NULL,
  updateduser STRING NOT NULL,
  updateddate DATETIME NOT NULL,
  lnd_updatedate DATETIME,
  lnd_updatetype STRING,
  src_changedate DATETIME
)Cluster by imagereviewresultimageid
;