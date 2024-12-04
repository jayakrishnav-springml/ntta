## Translation time: 2024-03-04T06:44:00.523569Z
## Translation job ID: a86d938d-fa65-424d-bf4e-0008985e1778
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_TBOS/Tables/Stage_TP_Customer_OutboundCommunications.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_TBOS_STAGE_CDC.DocMgr_TP_Customer_OutboundCommunications
(
  outboundcommunicationid INT64 NOT NULL,
  customerid INT64 NOT NULL,
  documenttype STRING NOT NULL,
  communicationdate DATETIME,
  generateddate DATETIME,
  description STRING,
  documentpath STRING,
  initiatedby STRING,
  queueid INT64,
  isdelivered INT64,
  paymentid INT64,
  deliverydate DATETIME,
  readdate DATETIME,
  generatedby INT64,
  filepathconfigurationid INT64,
  createddate DATETIME NOT NULL,
  createduser STRING NOT NULL,
  updateddate DATETIME NOT NULL,
  updateduser STRING NOT NULL,
  lnd_updatedate DATETIME,
  lnd_updatetype STRING,
  src_changedate DATETIME
)
CLUSTER BY OutboundCommunicationID
;