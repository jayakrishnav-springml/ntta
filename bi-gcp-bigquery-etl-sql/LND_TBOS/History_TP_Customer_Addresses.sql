## Translation time: 2024-03-13T05:19:34.327071Z
## Translation job ID: 0a711804-adbe-4db7-8cda-d8808bd4ce52
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/NTTA_Missing_DDLs/LND_TBOS_History_TP_Customer_Addresses.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_TBOS.History_TP_Customer_Addresses
(
  custaddressid INT64 NOT NULL,
  customerid INT64 NOT NULL,
  addresstype STRING,
  addressline1 STRING,
  addressline2 STRING,
  addressline3 STRING,
  city STRING,
  state STRING,
  country STRING,
  zip1 STRING,
  zip2 STRING,
  isactive INT64 NOT NULL,
  iscommunication INT64 NOT NULL,
  createddate DATETIME NOT NULL,
  createduser STRING,
  updateddate DATETIME NOT NULL,
  updateduser STRING,
  histid INT64 NOT NULL,
  action STRING,
  isvalid INT64 NOT NULL,
  reasoncode STRING,
  addressupdateddate DATETIME,
  isaddressupdatenotified INT64,
  isvalidupdateddate DATETIME,
  isskiptraced INT64,
  addresssourceid INT64,
  rovsourceid INT64,
  rovsourcetype STRING,
  subsource STRING,
  movedtohistorydate DATETIME,
  icnid INT64,
  channelid INT64,
  lnd_updatedate DATETIME,
  lnd_updatetype STRING,
  src_changedate DATETIME
)
CLUSTER BY customerid
;