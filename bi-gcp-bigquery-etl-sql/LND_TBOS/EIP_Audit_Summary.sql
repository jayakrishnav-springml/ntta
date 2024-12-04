## Translation time: 2024-03-04T06:44:00.523569Z
## Translation job ID: a86d938d-fa65-424d-bf4e-0008985e1778
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_TBOS/Tables/EIP_Audit_Summary.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_TBOS.EIP_Audit_Summary
(
  agencycode STRING  NOT NULL,
  sourcecode INT64 NOT NULL,
  timestamp INT64 NOT NULL,
  txnsreceived INT64 NOT NULL,
  txnsaccepted INT64 NOT NULL,
  txnsrejected INT64 NOT NULL,
  txnsautoreadalpr INT64 NOT NULL,
  txnsautoreadvsr INT64 NOT NULL,
  txnsmirread INT64 NOT NULL,
  txnspendingmatch INT64 NOT NULL,
  txnspendingmir INT64 NOT NULL,
  txnspendingresponse INT64 NOT NULL,
  txnscompleted INT64 NOT NULL,
  createddate DATETIME NOT NULL,
  createduser STRING,
  updateddate DATETIME,
  updateduser STRING,
  lnd_updatedate DATETIME,
  lnd_updatetype STRING,
  src_changedate DATETIME
)
CLUSTER BY 
sourcecode,timestamp;