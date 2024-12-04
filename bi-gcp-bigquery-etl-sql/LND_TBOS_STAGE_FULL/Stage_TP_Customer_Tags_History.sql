## Translation time: 2024-03-04T06:44:00.523569Z
## Translation job ID: a86d938d-fa65-424d-bf4e-0008985e1778
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_TBOS/Tables/Stage_TP_Customer_Tags_History.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_TBOS_STAGE_FULL.TollPlus_TP_Customer_Tags_History
(
  custtagid INT64 NOT NULL,
  customerid INT64 NOT NULL,
  tagstartdate DATETIME NOT NULL,
  tagenddate DATETIME NOT NULL,
  tagtype STRING,
  tagstatus STRING,
  tagalias STRING,
  hextagid STRING,
  serialno STRING,
  histid INT64 NOT NULL,
  action STRING,
  returnedorassignedtype STRING,
  itemcode STRING,
  isnonrevenue INT64,
  isgroundtransportation INT64,
  tagagency STRING,
  specialitytag STRING,
  mounting STRING,
  isdfwblocked_dropping INT64,
  isdalblocked_dropping INT64,
  icnid INT64,
  tagassigneddate DATETIME,
  tagstatusdate DATETIME,
  channelid INT64,
  tagassignedenddate DATETIME,
  createddate DATETIME NOT NULL,
  createduser STRING,
  updateddate DATETIME NOT NULL,
  updateduser STRING,
  lnd_updatedate DATETIME,
  lnd_updatetype STRING,
  src_changedate DATETIME
)
CLUSTER BY HistID
;