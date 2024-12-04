## Translation time: 2024-03-04T06:44:00.523569Z
## Translation job ID: a86d938d-fa65-424d-bf4e-0008985e1778
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_TBOS/Tables/EIP_VehicleImages.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_TBOS.EIP_VehicleImages
(
  txnimageid INT64 NOT NULL,
  transactionid INT64 NOT NULL,
  imagename STRING,
  imageindex INT64 NOT NULL,
  imagerows INT64,
  imagecols INT64,
  cameraname STRING NOT NULL,
  cameraview STRING NOT NULL,
  cameraid STRING NOT NULL,
  cameratype INT64,
  signaturetype INT64,
  ocrindex INT64,
  vsrhandle STRING,
  vsrconfidence INT64,
  vsrcharresults STRING,
  vsrloactionright INT64,
  vsrloactionleft INT64,
  vsrloactiontop INT64,
  vsrloactionbottom INT64,
  roihorizontalposition INT64,
  roihorizontalsize INT64,
  roiverticalposition INT64,
  roiverticalsize INT64,
  issignaturevalid INT64,
  isdayimage INT64,
  imagecontrast NUMERIC(31, 2),
  imagebrightness NUMERIC(31, 2),
  disposition INT64,
  reasoncode INT64,
  roiimagename STRING,
  roiimagepathid STRING,
  roiimagepath STRING,
  ocrimagepathid STRING,
  ocrimagepath STRING,
  ocrregistrationconfidence INT64,
  ocrjurisdictionconfidence INT64,
  ocrimagename STRING,
  createddate DATETIME,
  createduser STRING,
  updateddate DATETIME,
  updateduser STRING,
  lnd_updatedate DATETIME,
  lnd_updatetype STRING,
  src_changedate DATETIME
)
CLUSTER BY
txnimageid
;