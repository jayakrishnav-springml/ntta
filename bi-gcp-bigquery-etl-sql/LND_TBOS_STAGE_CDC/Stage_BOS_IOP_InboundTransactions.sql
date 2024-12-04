## Translation time: 2024-03-04T06:44:00.523569Z
## Translation job ID: a86d938d-fa65-424d-bf4e-0008985e1778
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_TBOS/Tables/Stage_BOS_IOP_InboundTransactions.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_TBOS_STAGE_CDC.TollPlus_BOS_IOP_InboundTransactions
(
  bosioptransactionid INT64 NOT NULL,
  fileid INT64 NOT NULL,
  ioptransactionid INT64 NOT NULL,
  transactiontypeid INT64 NOT NULL,
  tagtype STRING,
  entrytransactiondate DATETIME NOT NULL,
  agencyid STRING,
  entryplaza STRING,
  entrylane STRING,
  tagstatus STRING,
  licencenumber STRING,
  licensestate STRING,
  exitplaza STRING,
  exitlane STRING,
  responsestatus STRING,
  tollamount NUMERIC(31, 2) NOT NULL,
  acceptedamount NUMERIC(31, 2),
  discountplanid INT64,
  customertripid INT64,
  vehicleclass STRING,
  tagserialnumber STRING,
  exittransactiondate DATETIME,
  debitorcredit STRING,
  createddate DATETIME NOT NULL,
  createduser STRING,
  updateddate DATETIME NOT NULL,
  updateduser STRING,
  lnd_updatedate DATETIME,
  lnd_updatetype STRING,
  src_changedate DATETIME
)cluster by bosioptransactionid
;