## Translation time: 2024-03-04T06:44:00.523569Z
## Translation job ID: a86d938d-fa65-424d-bf4e-0008985e1778
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_TBOS/Tables/TollPlus_DMVExceptionDetails.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_TBOS.TollPlus_DMVExceptionDetails
(
  exceptiondetailsid INT64 NOT NULL,
  exceptionqueueid INT64 NOT NULL,
  customerid INT64,
  datamartid INT64,
  tptripid INT64,
  linksourcename STRING,
  vin STRING,
  documentnumber STRING,
  platenumber STRING NOT NULL,
  registrationstate STRING NOT NULL,
  registrationcountry STRING,
  platetype STRING,
  vehiclemake STRING,
  vehiclemodel STRING,
  vehicleyear INT64,
  vehiclecolor STRING,
  vehicleclassname STRING,
  vehicleclasscode STRING,
  vehiclestarteffeictivedate DATETIME,
  vehicleendeffeictivedate DATETIME,
  ownerfirstname STRING,
  ownerlastname STRING,
  ownermiddlename STRING,
  owneraddress1 STRING,
  owneraddress2 STRING,
  ownercity STRING,
  ownerstate STRING,
  ownercountry STRING,
  ownerzip1 STRING,
  ownerzip2 STRING,
  renewalfirstname STRING,
  renewallastname STRING,
  renewalmiddlename STRING,
  renewaladdress1 STRING,
  renewaladdress2 STRING,
  renewalcity STRING,
  renewalstate STRING,
  renewalcountry STRING,
  renewalzip1 STRING,
  renewalzip2 STRING,
  isvalid INT64,
  createddate DATETIME NOT NULL,
  createduser STRING,
  updateddate DATETIME NOT NULL,
  updateduser STRING,
  lnd_updatedate DATETIME,
  lnd_updatetype STRING,
  src_changedate DATETIME
)
cluster by exceptiondetailsid
;