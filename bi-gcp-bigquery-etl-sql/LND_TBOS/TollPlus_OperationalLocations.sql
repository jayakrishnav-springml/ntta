## Translation time: 2024-03-04T06:44:00.523569Z
## Translation job ID: a86d938d-fa65-424d-bf4e-0008985e1778
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_TBOS/Tables/TollPlus_OperationalLocations.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_TBOS.TollPlus_OperationalLocations
(
  operationallocationid INT64 NOT NULL,
  locationname STRING NOT NULL,
  locationcode STRING NOT NULL,
  locationdesc STRING,
  address1 STRING,
  city STRING,
  state STRING,
  zipcode STRING,
  isthirdpartylocation INT64 NOT NULL,
  locationtype STRING,
  retaileruserid INT64,
  iswarehouse INT64 NOT NULL,
  issemafoneenabled INT64 NOT NULL,
  isactive INT64 NOT NULL,
  islinkedtouser INT64 NOT NULL,
  encryptedlocation STRING,
  merchantid STRING,
  hostedsecureid STRING,
  hostedsecureapitoken STRING,
  issendtagrequesttortp INT64 NOT NULL,
  channelid INT64,
  icnid INT64,
  isnew INT64 NOT NULL,
  createddate DATETIME,
  createduser STRING,
  updateddate DATETIME,
  updateuser STRING,
  lnd_updatedate DATETIME,
  lnd_updatetype STRING,
  src_changedate DATETIME
)
CLUSTER BY OperationalLocationID
;