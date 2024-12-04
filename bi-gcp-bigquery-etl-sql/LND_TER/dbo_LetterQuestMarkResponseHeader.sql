-- Translation time: 2024-06-04T08:06:27.696231Z
-- Translation job ID: a4465f30-9e78-4d9a-ad69-bbfb39271a9b
-- Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_TER/Tables/dbo_LetterQuestMarkResponseHeader.sql
-- Translated from: SqlServer
-- Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_TER.LetterQuestMarkResponseHeader
(
  letterquestmarkresponseheaderid INT64 NOT NULL,
  lettertype STRING NOT NULL,
  letterdate DATETIME NOT NULL,
  lettercount INT64 NOT NULL,
  datafilesize INT64,
  datafilecontenttype STRING,
  countfilesize INT64,
  countfilecontenttype STRING,
  createddate DATETIME NOT NULL,
  createdby STRING NOT NULL,
  updateddate DATETIME,
  updatedby STRING,
  last_update_type STRING NOT NULL,
  last_update_date DATETIME NOT NULL
)
;
