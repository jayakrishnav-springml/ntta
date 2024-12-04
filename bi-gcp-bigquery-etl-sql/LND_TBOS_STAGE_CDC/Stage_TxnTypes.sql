## Translation time: 2024-03-04T06:44:00.523569Z
## Translation job ID: a86d938d-fa65-424d-bf4e-0008985e1778
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_TBOS/Tables/Stage_TxnTypes.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_TBOS_STAGE_CDC.Finance_TxnTypes
(
  txntypeid INT64 NOT NULL,
  txntype STRING NOT NULL,
  txndesc STRING,
  txntype_categoryid INT64 NOT NULL,
  statementnote STRING,
  customernote STRING,
  violatornote STRING,
  isautomatic INT64 NOT NULL,
  adjustmentcategoryid INT64,
  levelid INT64 NOT NULL,
  status STRING,
  levelcode STRING,
  businessunitid INT64,
  createddate DATETIME NOT NULL,
  createduser STRING,
  updateddate DATETIME NOT NULL,
  updateduser STRING,
  lnd_updatedate DATETIME,
  lnd_updatetype STRING,
  src_changedate DATETIME
)
CLUSTER BY txntypeid
;