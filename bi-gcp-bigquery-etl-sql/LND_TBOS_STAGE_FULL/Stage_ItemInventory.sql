## Translation time: 2024-03-04T06:44:00.523569Z
## Translation job ID: a86d938d-fa65-424d-bf4e-0008985e1778
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_TBOS/Tables/Stage_ItemInventory.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_TBOS_STAGE_FULL.Inventory_ItemInventory
(
  inventoryid INT64 NOT NULL,
  itemcode STRING,
  facilitycode STRING,
  hextagid STRING,
  serialno STRING,
  customerid INT64,
  locationid INT64 NOT NULL,
  shipmentid INT64 NOT NULL,
  batchid INT64 NOT NULL,
  mfgdate DATETIME NOT NULL,
  warrantystartdate DATETIME,
  warrantyenddate DATETIME,
  rmanumber STRING,
  invstatusdate DATETIME,
  itemtype STRING,
  itemstatus STRING,
  itemid STRING,
  ccn STRING,
  tagagency STRING,
  frame24 STRING,
  frame25 STRING,
  frame26 STRING,
  frame27 STRING,
  transponderauditid INT64,
  startdate DATETIME,
  enddate DATETIME,
  tagreqid INT64,
  retaileruserid INT64,
  channelid INT64,
  icnid INT64,
  createddate DATETIME NOT NULL,
  createduser STRING,
  updateddate DATETIME NOT NULL,
  updateduser STRING,
  lnd_updatedate DATETIME,
  lnd_updatetype STRING,
  src_changedate DATETIME
)
CLUSTER BY
inventoryid
;