## Translation time: 2024-03-04T06:44:00.523569Z
## Translation job ID: a86d938d-fa65-424d-bf4e-0008985e1778
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_TBOS/Tables/Stage_Adjustments.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_TBOS_STAGE_CDC.Finance_Adjustments
(
  adjustmentid INT64 NOT NULL,
  customerid INT64 NOT NULL,
  accstatusid INT64 NOT NULL,
  amount NUMERIC(31, 2) NOT NULL,
  adjustmentcategory STRING,
  txntypeid INT64 NOT NULL,
  adjustmentdate DATETIME NOT NULL,
  drcrflag STRING,
  adjustmentreason STRING,
  ismanualentry INT64,
  approvedstatusid INT64 NOT NULL,
  approvedstatusdate DATETIME NOT NULL,
  paymentid INT64,
  icnid INT64,
  locationid INT64,
  sourceid INT64,
  sourcename STRING,
  tolladjustmentid INT64,
  comments STRING,
  newadjustmentid INT64 NOT NULL,
  iscreditcardtype INT64 NOT NULL,
  sourcetranstypeid INT64,
  sourcertdid INT64,
  refundrequestid INT64 NOT NULL,
  createddate DATETIME NOT NULL,
  createduser STRING,
  updateddate DATETIME NOT NULL,
  updateduser STRING,
  lnd_updatedate DATETIME,
  lnd_updatetype STRING,
  src_changedate DATETIME
) cluster by adjustmentid
;