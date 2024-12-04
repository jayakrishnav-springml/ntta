## Translation time: 2024-03-04T06:44:00.523569Z
## Translation job ID: a86d938d-fa65-424d-bf4e-0008985e1778
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_TBOS/Tables/Stage_CustomerNotificationQueue.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_TBOS_STAGE_FULL.Notifications_CustomerNotificationQueue
(
  customernotificationqueueid INT64 NOT NULL,
  configalerttypealertchannelid INT64,
  customerid INT64,
  custcorrespondlogid INT64,
  jsondatakey STRING,
  jsondatacommon STRING,
  notifstatus INT64,
  parentcustomernotificationqueueid INT64,
  requesteddate DATETIME,
  linkid INT64,
  linksource STRING,
  fileid INT64,
  remarks STRING,
  mbsreprint STRING,
  createduser STRING NOT NULL,
  createddate DATETIME NOT NULL,
  updateduser STRING,
  updateddate DATETIME,
  lnd_updatedate DATETIME,
  lnd_updatetype STRING,
  src_changedate DATETIME
)
CLUSTER BY customernotificationqueueid
;