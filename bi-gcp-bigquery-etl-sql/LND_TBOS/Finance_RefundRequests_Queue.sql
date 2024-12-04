## Translation time: 2024-03-04T06:44:00.523569Z
## Translation job ID: a86d938d-fa65-424d-bf4e-0008985e1778
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_TBOS/Tables/Finance_RefundRequests_Queue.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_TBOS.Finance_RefundRequests_Queue
(
  refundrequestid INT64 NOT NULL,
  exceptionrrid INT64,
  customerid INT64,
  refundrequeststate STRING,
  refundrequesttype STRING,
  subsystem STRING,
  txntypeid INT64,
  paytypeid INT64,
  originalpaytypeid INT64,
  amount NUMERIC(31, 2),
  paymenttxnid INT64,
  requesteddate DATETIME,
  processeddate DATETIME,
  reason STRING,
  approveddate DATETIME,
  approvedby STRING,
  retrycnt INT64 NOT NULL,
  icnid INT64,
  createddate DATETIME NOT NULL,
  createduser STRING NOT NULL,
  updateddate DATETIME NOT NULL,
  updateduser STRING NOT NULL,
  lnd_updatedate DATETIME,
  lnd_updatetype STRING,
  src_changedate DATETIME
)
CLUSTER BY
refundrequestid
;