## Translation time: 2024-03-04T06:44:00.523569Z
## Translation job ID: a86d938d-fa65-424d-bf4e-0008985e1778
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_TBOS/Tables/Stage_ConfigAlertTypeAlertChannels.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_TBOS_STAGE_FULL.Notifications_ConfigAlertTypeAlertChannels
(
  configalerttypealertchannelid INT64 NOT NULL,
  alerttypeid INT64,
  alertchannelid INT64,
  templateid INT64,
  templatequery STRING,
  sender INT64,
  isactive INT64 NOT NULL,
  chargetocustomer NUMERIC(31, 2),
  remarks STRING,
  orderno INT64,
  sourcetable STRING,
  textmessage STRING,
  channelid INT64,
  icnid INT64,
  createduser STRING NOT NULL,
  createddate DATETIME NOT NULL,
  updateduser STRING,
  updateddate DATETIME,
  lnd_updatedate DATETIME,
  lnd_updatetype STRING,
  src_changedate DATETIME
)
CLUSTER BY configalerttypealertchannelid
;