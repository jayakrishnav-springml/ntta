-- Translation time: 2024-06-04T08:06:27.696231Z
-- Translation job ID: a4465f30-9e78-4d9a-ad69-bbfb39271a9b
-- Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_TER/Tables/dbo_LetterQuestMarkResponse.sql
-- Translated from: SqlServer
-- Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_TER.LetterQuestMarkResponse
(
  letterquestmarkresponseid INT64 NOT NULL,
  letterquestmarkrequestid INT64 NOT NULL,
  violatorid INT64 NOT NULL,
  vidseq INT64 NOT NULL,
  letterquestmarkresponseheaderid INT64 NOT NULL,
  typenotice STRING NOT NULL,
  mailed STRING NOT NULL,
  notmailedreason STRING,
  maildate DATETIME,
  firstname STRING,
  lastname STRING,
  ncoadate DATETIME,
  address1 STRING,
  address2 STRING,
  city STRING,
  statelookupid STRING,
  zipcode STRING,
  plus4 STRING,
  county STRING,
  country STRING,
  createddate DATETIME NOT NULL,
  createdby STRING NOT NULL,
  updateddate DATETIME,
  updatedby STRING,
  last_update_type STRING NOT NULL,
  last_update_date DATETIME NOT NULL
)
;
