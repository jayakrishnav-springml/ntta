-- Translation time: 2024-06-04T08:06:27.696231Z
-- Translation job ID: a4465f30-9e78-4d9a-ad69-bbfb39271a9b
-- Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_TER/Tables/dbo_BanOfficerLookup.sql
-- Translated from: SqlServer
-- Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_TER.BanOfficerLookup
(
  banofficerlookupid INT64 NOT NULL,
  lastname STRING NOT NULL,
  firstname STRING NOT NULL,
  phonenbr STRING,
  radionbr STRING,
  unit STRING,
  registration STRING,
  patrolcar STRING,
  area STRING,
  activeflag INT64 NOT NULL,
  createddate DATETIME NOT NULL,
  createdby STRING NOT NULL,
  updateddate DATETIME,
  updatedby STRING,
  last_update_type STRING NOT NULL,
  last_update_date DATETIME NOT NULL
)
cluster by banofficerlookupid
;
