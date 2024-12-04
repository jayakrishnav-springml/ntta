## Translation time: 2024-03-04T06:44:00.523569Z
## Translation job ID: a86d938d-fa65-424d-bf4e-0008985e1778
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_TBOS/Tables/TranProcessing_TSAImageRawTransactions.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_TBOS.TranProcessing_TSAImageRawTransactions
(
  imgtxnid INT64 NOT NULL,
  txnid INT64,
  separator STRING,
  imagefilename STRING,
  imagelocationtype STRING,
  imagefacing STRING,
  licenseplatestate STRING,
  licenseplatestateconfidencelevel INT64,
  licenseplatecountry STRING,
  licenseplatecountryconfidencelevel INT64,
  licenseplatevalue STRING,
  licenseplatevalueconfidencelevel INT64,
  licenseplatetype STRING,
  licenseplatetypeconfidencelevel INT64,
  ocrenginetype STRING,
  licenseplateoverallconfidencelevel INT64,
  regionofinterestroicoordinateupperleftx INT64,
  regionofinterestroicoordinateupperlefty INT64,
  regionofinterestroicoordinatelowerrightx INT64,
  regionofinterestroicoordinatelowerrighty INT64,
  licenseplatestatus STRING,
  isimagevalid INT64,
  reasoncode STRING,
  sourcepkid INT64,
  createddate DATETIME,
  createduser STRING,
  updateddate DATETIME,
  updateduser STRING,
  lnd_updatedate DATETIME,
  lnd_updatetype STRING,
  src_changedate DATETIME
) cluster by imgtxnid
;