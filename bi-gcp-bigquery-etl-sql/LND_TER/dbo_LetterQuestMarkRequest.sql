-- Translation time: 2024-06-04T08:06:27.696231Z
-- Translation job ID: a4465f30-9e78-4d9a-ad69-bbfb39271a9b
-- Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_TER/Tables/dbo_LetterQuestMarkRequest.sql
-- Translated from: SqlServer
-- Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_TER.LetterQuestMarkRequest
(
  letterquestmarkrequestid INT64 NOT NULL,
  violatorid INT64 NOT NULL,
  vidseq INT64 NOT NULL,
  letterquestmarkrequestheaderid INT64 NOT NULL,
  processedflag INT64,
  processeddate DATETIME,
  confirmedflag INT64,
  confirmeddate DATETIME,
  createddate DATETIME NOT NULL,
  createdby STRING,
  updateddate DATETIME,
  updatedby STRING
)
;
