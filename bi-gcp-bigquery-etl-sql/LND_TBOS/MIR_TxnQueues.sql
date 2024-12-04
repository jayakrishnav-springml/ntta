## Translation time: 2024-03-04T06:44:00.523569Z
## Translation job ID: a86d938d-fa65-424d-bf4e-0008985e1778
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_TBOS/Tables/MIR_TxnQueues.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_TBOS.MIR_TxnQueues
(
  queueid INT64 NOT NULL,
  queuename STRING NOT NULL,
  queuecode STRING NOT NULL,
  `queue description` STRING NOT NULL,
  maxtranstopull INT64,
  createduser STRING NOT NULL,
  createddate DATETIME NOT NULL,
  updateduser STRING NOT NULL,
  updateddate DATETIME NOT NULL,
  lnd_updatedate DATETIME,
  lnd_updatetype STRING,
  src_changedate DATETIME
)
CLUSTER BY
queueid;