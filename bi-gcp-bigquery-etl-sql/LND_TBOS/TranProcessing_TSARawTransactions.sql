## Translation time: 2024-03-04T06:44:00.523569Z
## Translation job ID: a86d938d-fa65-424d-bf4e-0008985e1778
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_TBOS/Tables/TranProcessing_TSARawTransactions.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_TBOS.TranProcessing_TSARawTransactions
(
  txnid INT64 NOT NULL,
  transactiontype STRING,
  recordtype STRING,
  subscriberuniquetransactionid INT64,
  resubmittalreason STRING,
  resubmittalcount INT64,
  authorityid STRING,
  locationtype STRING,
  facility STRING,
  subscriberid STRING,
  entryinformation STRING,
  plaza STRING,
  lane INT64,
  lanemode STRING,
  transactiondate STRING,
  transactiontime STRING,
  transponderid STRING,
  transponderstatus STRING,
  transpondervalidationlistfilename STRING,
  licenseplatevalidationlistfilename STRING,
  vehicleclassification STRING,
  axlesexpected INT64,
  axlescounted INT64,
  speed INT64,
  hovdesignation STRING,
  exitbarrierorgantryinformation STRING,
  collectorid INT64,
  vaultid INT64,
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
  hostbosid INT64,
  fileid INT64,
  sourcepkid INT64,
  ismalformed INT64 NOT NULL,
  isunabletoparse INT64 NOT NULL,
  createddate DATETIME NOT NULL,
  createduser STRING NOT NULL,
  updateddate DATETIME NOT NULL,
  updateduser STRING NOT NULL,
  lnd_updatedate DATETIME,
  lnd_updatetype STRING,
  src_changedate DATETIME
) cluster by txnid
;