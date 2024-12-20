## Translation time: 2024-03-04T06:44:00.523569Z
## Translation job ID: a86d938d-fa65-424d-bf4e-0008985e1778
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_TBOS/Tables/TSA_TSATripAttributes.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_TBOS.TSA_TSATripAttributes
(
  ttptripid INT64 NOT NULL,
  tptripid INT64,
  subscriberuniquetransactionid INT64,
  authorityid STRING,
  subscriberid STRING,
  transponderid STRING,
  collectorid INT64,
  vaultid INT64,
  validtxnprimarykeyid INT64,
  sourcetripid INT64,
  sourcepkid INT64,
  transactiontype STRING,
  recordtype STRING,
  resubmittalreason STRING,
  resubmittalcount INT64,
  locationtype STRING,
  facility STRING,
  entryinformation STRING,
  plaza STRING,
  lane INT64,
  lanemode STRING,
  transactiondate STRING,
  transactiontime STRING,
  transponderstatus STRING,
  transpondervalidationlistfilename STRING,
  licenseplatevalidationlistfilename STRING,
  vehicleclassification STRING,
  axlesexpected INT64,
  axlescounted INT64,
  speed INT64,
  hovdesignation STRING,
  exitbarrierorgantryinformation STRING,
  vehicleclassificationfortolldetermination STRING,
  transpondertollamount NUMERIC(31, 2),
  transponderdiscounttype STRING,
  discountedtranspondertollamount NUMERIC(31, 2),
  videotollamountwithoutvideotollpremium NUMERIC(31, 2),
  videotollamountwithvideotollpremium NUMERIC(31, 2),
  videodiscounttype STRING,
  discountedvideotollamountwithoutvideotollpremium NUMERIC(31, 2),
  discountedvideotollamountwithvideotollpremium NUMERIC(31, 2),
  cashtollamount NUMERIC(31, 2),
  cashdiscounttype STRING,
  discountedcashtollamount NUMERIC(31, 2),
  amountpaid NUMERIC(31, 2),
  unusualoccurrencecode STRING,
  numberofimages INT64,
  transactionstatus STRING,
  disposition STRING,
  lastvalidrecordcount INT64,
  originaltransactiontype STRING,
  postedamount NUMERIC(31, 2),
  correctioncount INT64,
  originalexittransactiondatetime STRING,
  bmsalertdate DATETIME,
  pbmtollamount NUMERIC(31, 2),
  avitollamount NUMERIC(31, 2),
  invoicestatus STRING,
  rejectreason STRING,
  basefee NUMERIC(31, 2),
  variablefee NUMERIC(31, 2),
  interoptransactionfee NUMERIC(31, 2),
  netpayamount NUMERIC(31, 2),
  subscriberidfromfile STRING,
  calculatedvideoamtwithvideopremium NUMERIC(31, 2),
  calculateddiscountedvideoamtwithvideopremium NUMERIC(31, 2),
  revenuedate DATETIME,
  createddate DATETIME,
  updateddate DATETIME,
  createduser STRING,
  updateduser STRING,
  lnd_updatedate DATETIME,
  lnd_updatetype STRING,
  src_changedate DATETIME
)
CLUSTER BY
ttptripid
;