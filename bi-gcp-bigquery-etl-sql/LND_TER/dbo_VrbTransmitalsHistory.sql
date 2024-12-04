-- Translation time: 2024-06-04T08:06:27.696231Z
-- Translation job ID: a4465f30-9e78-4d9a-ad69-bbfb39271a9b
-- Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_TER/Tables/dbo_VrbTransmitalsHistory.sql
-- Translated from: SqlServer
-- Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_TER.VrbTransmitalsHistory
(
  vrbtransmitalshistoryid INT64 NOT NULL,
  vrbtransmitalsid INT64 NOT NULL,
  vrbid INT64 NOT NULL,
  violatorid INT64 NOT NULL,
  vidseq INT64 NOT NULL,
  sentdate DATETIME NOT NULL,
  reason STRING NOT NULL,
  vrbagencylookupid INT64 NOT NULL,
  processname STRING NOT NULL,
  createddate DATETIME NOT NULL,
  createdby STRING NOT NULL,
  updateddate DATETIME,
  updatedby STRING,
  licplatenbr STRING,
  docnum STRING,
  last_update_type STRING,
  last_update_date DATETIME
)
;
