-- Translation time: 2024-06-04T08:06:27.696231Z
-- Translation job ID: a4465f30-9e78-4d9a-ad69-bbfb39271a9b
-- Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_TER/Tables/dbo_PaymentPlanViolator.sql
-- Translated from: SqlServer
-- Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_TER.PaymentPlanViolator
(
  paymentplanviolatorid INT64 NOT NULL,
  violatorid INT64 NOT NULL,
  vidseq INT64 NOT NULL,
  paymentplanid INT64 NOT NULL,
  paymentplanviolatorseq INT64 NOT NULL,
  hvflag INT64 NOT NULL,
  vehiclemake STRING,
  vehiclemodel STRING,
  vehicleyear STRING,
  licenseplatenbr STRING,
  statelookupid INT64 NOT NULL,
  lastinvoicenbr INT64 NOT NULL,
  violationamt NUMERIC(33, 4),
  zipcashamt NUMERIC(33, 4),
  adminfeecount INT64,
  citationcount INT64,
  collectionsreceived NUMERIC(33, 4),
  deletedflag INT64 NOT NULL,
  createddate DATETIME NOT NULL,
  createdby STRING NOT NULL,
  updateddate DATETIME,
  updatedby STRING
)
;
