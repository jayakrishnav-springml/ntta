## Translation time: 2024-03-04T06:41:57.683170Z
## Translation job ID: 00dc6676-2c12-444a-b02a-71c7788bdc89
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/EDW_TRIPS/Tables/Stage_TSATripAttributes.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_TRIPS_STAGE.TSATripAttributes
(
  tptripid INT64 NOT NULL,
  sourcetripid INT64,
  tripdate DATETIME,
  recordtype STRING,
  vehiclespeed INT64,
  vehicleclassification STRING,
  transactiontype STRING,
  transpondertollamount NUMERIC(31, 2),
  videotollamountwithvideotollpremium NUMERIC(31, 2),
  videotollamountwithoutvideotollpremium NUMERIC(31, 2),
  tsa_receivedtollamount NUMERIC(31, 2),
  tsa_base NUMERIC(31, 2),
  tsa_premium NUMERIC(31, 2),
  transponderdiscounttype STRING,
  discountedtranspondertollamount NUMERIC(31, 2),
  videodiscounttype STRING,
  discountedvideotollamountwithoutvideotollpremium NUMERIC(31, 2),
  discountedvideotollamountwithvideotollpremium NUMERIC(31, 2),
  lnd_updatedate DATETIME,
  edw_updatedate DATETIME
)CLUSTER    BY tptripid
;