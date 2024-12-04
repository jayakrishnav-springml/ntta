-- Translation time: 2024-06-04T08:06:27.696231Z
-- Translation job ID: a4465f30-9e78-4d9a-ad69-bbfb39271a9b
-- Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_TER/Tables/dbo_ViolatorAmountsSummary.sql
-- Translated from: SqlServer
-- Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_TER.ViolatorAmountsSummary
(
  violatoramountssummaryid INT64 NOT NULL,
  violatorid INT64 NOT NULL,
  vidseq INT64 NOT NULL,
  hvqamountdue NUMERIC(33, 4) NOT NULL,
  hvqtollsdue NUMERIC(33, 4) NOT NULL,
  hvqtransactions INT64,
  hvqfeesdue NUMERIC(33, 4) NOT NULL,
  totalamountdue NUMERIC(33, 4) NOT NULL,
  totaltollsdue NUMERIC(33, 4),
  totalfeesdue NUMERIC(33, 4),
  totalcitationcount INT64 NOT NULL,
  totaltransactionscount INT64 NOT NULL,
  createddate DATETIME NOT NULL,
  createdby STRING NOT NULL,
  updateddate DATETIME,
  updatedby STRING,
  last_update_type STRING NOT NULL,
  last_update_date DATETIME NOT NULL
)
;
