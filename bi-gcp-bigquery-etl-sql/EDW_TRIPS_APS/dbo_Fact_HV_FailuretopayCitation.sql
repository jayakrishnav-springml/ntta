## Translation time: 2024-03-04T06:41:57.683170Z
## Translation job ID: 00dc6676-2c12-444a-b02a-71c7788bdc89
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/EDW_TRIPS/Tables/dbo_Fact_HV_FailuretopayCitation.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_TRIPS_APS.Fact_HV_FailuretopayCitation
(
  failurecitationid INT64,
  hvid INT64 NOT NULL,
  customerid INT64 NOT NULL,
  citationid INT64 NOT NULL,
  tptripid INT64,
  citationinvoiceid INT64 NOT NULL,
  mbsid INT64 NOT NULL,
  laneid INT64,
  courtid INT64,
  judgeid INT64,
  dpstrooperid INT64 NOT NULL,
  citationstatusid INT64 NOT NULL,
  invoiceagestageid INT64 NOT NULL,
  citationinvoicenumber INT64 NOT NULL,
  citationnumber STRING,
  dpscitationnumber STRING,
  tripdayid INT64,
  maildayid INT64,
  dpscitationissueddayid INT64,
  citationpackagecreateddayid INT64,
  courtappearancedate DATETIME,
  printdate DATETIME,
  firstpaiddate DATETIME,
  lastpaiddate DATETIME,
  activeflag INT64,
  migratedflag INT64 NOT NULL,
  txntollamount NUMERIC(33, 4),
  txntollspaid NUMERIC(33, 4),
  tollsoninvoice NUMERIC(33, 4),
  tollspaidoninvoice NUMERIC(33, 4),
  feesdueoninvoice NUMERIC(33, 4),
  feespaidoninvoice NUMERIC(33, 4),
  tollsadjustedoninvoice NUMERIC(31, 2),
  edw_updatedate DATETIME NOT NULL
)
cluster by failurecitationid
;