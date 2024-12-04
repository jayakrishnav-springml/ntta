-- Translation time: 2024-06-04T08:06:27.696231Z
-- Translation job ID: a4465f30-9e78-4d9a-ad69-bbfb39271a9b
-- Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_TER/Tables/dbo_Violator.sql
-- Translated from: SqlServer
-- Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_TER.Violator
(
  violatorid INT64 NOT NULL,
  vidseq INT64 NOT NULL,
  licplatenbr STRING NOT NULL,
  licplatestatelookupid INT64 NOT NULL,
  vehiclemake STRING,
  vehiclemodel STRING,
  vehicleyear STRING,
  docnum STRING,
  vin STRING,
  primaryviolatorfname STRING,
  primaryviolatorlname STRING,
  secondaryviolatorfname STRING,
  secondaryviolatorlname STRING,
  driverslicense STRING,
  driverslicensestatelookupid INT64 NOT NULL,
  secondarydriverslicense STRING,
  secondarydriverslicensestatelookupid INT64 NOT NULL,
  earliesthvtrandate DATETIME NOT NULL,
  latesthvtrandate DATETIME NOT NULL,
  admincountylookupid INT64 NOT NULL,
  registrationcountylookupid INT64 NOT NULL,
  registrationdatenextmonth INT64,
  registrationdatenextyear INT64,
  violatoragencylookupid INT64 NOT NULL,
  createddate DATETIME NOT NULL,
  createdby STRING NOT NULL,
  updateddate DATETIME,
  updatedby STRING,
  last_update_type STRING,
  last_update_date DATETIME
)
;
