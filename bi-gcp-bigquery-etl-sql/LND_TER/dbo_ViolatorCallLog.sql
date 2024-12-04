-- Translation time: 2024-06-04T08:06:27.696231Z
-- Translation job ID: a4465f30-9e78-4d9a-ad69-bbfb39271a9b
-- Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_TER/Tables/dbo_ViolatorCallLog.sql
-- Translated from: SqlServer
-- Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_TER.ViolatorCallLog
(
  violatorcalllogid INT64 NOT NULL,
  violatorid INT64 NOT NULL,
  vidseq INT64 NOT NULL,
  violatorcallloglookupid INT64 NOT NULL,
  deletedflag INT64 NOT NULL,
  calldate DATETIME,
  outgoingcallflag INT64 NOT NULL,
  phonenbr STRING,
  connectedflag INT64 NOT NULL,
  comment STRING,
  createddate DATETIME NOT NULL,
  createdby STRING NOT NULL,
  updateddate DATETIME,
  updatedby STRING
)
;
