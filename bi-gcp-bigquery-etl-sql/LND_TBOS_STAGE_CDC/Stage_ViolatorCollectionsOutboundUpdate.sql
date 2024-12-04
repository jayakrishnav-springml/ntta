## Translation time: 2024-03-04T06:44:00.523569Z
## Translation job ID: a86d938d-fa65-424d-bf4e-0008985e1778
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_TBOS/Tables/Stage_ViolatorCollectionsOutboundUpdate.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_TBOS_STAGE_CDC.TER_ViolatorCollectionsOutboundUpdate
(
  viocolloutboundupdateid INT64 NOT NULL,
  fileid INT64,
  recordtype STRING,
  violatorid INT64,
  invoicenumber STRING,
  transactionid INT64,
  transactiontype STRING,
  transactionamount NUMERIC(31, 2),
  balaftertransaction NUMERIC(31, 2),
  transactiondate DATETIME,
  adjustmentreason STRING,
  createddate DATETIME,
  createduser STRING,
  updateddate DATETIME,
  updateduser STRING,
  lnd_updatedate DATETIME,
  lnd_updatetype STRING,
  src_changedate DATETIME
)
CLUSTER BY viocolloutboundupdateid
;