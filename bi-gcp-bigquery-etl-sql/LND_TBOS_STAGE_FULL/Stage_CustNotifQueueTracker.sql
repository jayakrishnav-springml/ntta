## Translation time: 2024-03-13T05:19:34.327071Z
## Translation job ID: 0a711804-adbe-4db7-8cda-d8808bd4ce52
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/NTTA_Missing_DDLs/LND_TBOS_Notifications_CustNotifQueueTracker.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_TBOS_STAGE_FULL.Notifications_CustNotifQueueTracker
(
  custnotifqueuetrackerid INT64 NOT NULL,
  customernotificationqueueid INT64,
  notifstatus INT64,
  processeddatetime DATETIME,
  remarks STRING,
  createduser STRING NOT NULL,
  createddate DATETIME NOT NULL,
  lnd_updatedate DATETIME,
  lnd_updatetype STRING,
  src_changedate DATETIME
)
CLUSTER BY custnotifqueuetrackerid
;