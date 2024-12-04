## Translation time: 2024-03-04T06:44:00.523569Z
## Translation job ID: a86d938d-fa65-424d-bf4e-0008985e1778
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_TBOS/Tables/Stage_AlertTypes.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_TBOS_STAGE_CDC.Notifications_AlertTypes
(
  alerttypeid INT64 NOT NULL,
  alerttype STRING,
  alerttypedesc STRING,
  configurableflag INT64,
  parent_alerttypeid INT64,
  ispaybymail INT64,
  ispostpaid INT64,
  isprepaid INT64,
  transmissiontype INT64,
  isactive INT64,
  seedlist INT64,
  ismobilewebsite INT64,
  channelid INT64,
  icnid INT64,
  groupname STRING,
  isportaldisplay INT64,
  createddate DATETIME NOT NULL,
  createduser STRING,
  updateddate DATETIME NOT NULL,
  updateduser STRING,
  lnd_updatedate DATETIME,
  lnd_updatetype STRING,
  src_changedate DATETIME
) cluster by alerttypeid
;