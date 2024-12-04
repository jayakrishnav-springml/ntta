-- Translation time: 2024-06-04T08:06:27.696231Z
-- Translation job ID: a4465f30-9e78-4d9a-ad69-bbfb39271a9b
-- Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_TER/Tables/dbo_LetterQuestMarkRequestHeader.sql
-- Translated from: SqlServer
-- Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_TER.LetterQuestMarkRequestHeader
(
  letterquestmarkrequestheaderid INT64 NOT NULL,
  lettertype STRING NOT NULL,
  letterdate DATETIME,
  lettercount INT64,
  datafilename STRING,
  datafilesize INT64,
  createddate DATETIME NOT NULL,
  createdby STRING NOT NULL,
  updateddate DATETIME,
  updatedby STRING,
  last_update_type STRING NOT NULL,
  last_update_date DATETIME NOT NULL
)
;
