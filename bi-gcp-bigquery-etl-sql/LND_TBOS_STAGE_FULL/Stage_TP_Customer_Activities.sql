## Translation time: 2024-03-04T06:44:00.523569Z
## Translation job ID: a86d938d-fa65-424d-bf4e-0008985e1778
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_TBOS/Tables/Stage_TP_Customer_Activities.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_TBOS_STAGE_FULL.TollPlus_TP_Customer_Activities
(
  activityid INT64 NOT NULL,
  customerid INT64,
  activitydate DATETIME NOT NULL,
  activitytype STRING,
  activitytext STRING,
  performedby STRING,
  subsystem STRING,
  activitysource STRING,
  linkid INT64 NOT NULL,
  linksourcename STRING,
  isactive INT64 NOT NULL,
  userlocation STRING,
  vehiclenumber STRING,
  vehiclestate STRING,
  tagid STRING,
  tagagency STRING,
  icnid INT64,
  outboundcommunicationid INT64,
  createddate DATETIME NOT NULL,
  createduser STRING,
  updateddate DATETIME NOT NULL,
  updateduser STRING,
  lnd_updatedate DATETIME,
  lnd_updatetype STRING,
  src_changedate DATETIME
)

CLUSTER BY ActivityID
;