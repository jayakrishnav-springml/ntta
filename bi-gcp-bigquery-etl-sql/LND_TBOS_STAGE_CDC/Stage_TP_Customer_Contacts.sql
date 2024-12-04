## Translation time: 2024-03-04T06:44:00.523569Z
## Translation job ID: a86d938d-fa65-424d-bf4e-0008985e1778
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_TBOS/Tables/Stage_TP_Customer_Contacts.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_TBOS_STAGE_CDC.TollPlus_TP_Customer_Contacts
(
  contactid INT64 NOT NULL,
  customerid INT64 NOT NULL,
  title STRING,
  suffix STRING,
  firstname STRING,
  middlename STRING,
  lastname STRING,
  gender STRING,
  nametype STRING NOT NULL,
  iscommunication INT64,
  dateofbirth DATE,
  firstname2 STRING,
  lastname2 STRING,
  icnid INT64,
  channelid INT64,
  race STRING,
  createddate DATETIME NOT NULL,
  createduser STRING,
  updateddate DATETIME NOT NULL,
  updateduser STRING,
  lnd_updatedate DATETIME,
  lnd_updatetype STRING,
  src_changedate DATETIME
)
CLUSTER BY ContactID
;