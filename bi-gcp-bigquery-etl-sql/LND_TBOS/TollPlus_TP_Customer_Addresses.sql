## Translation time: 2024-03-04T06:44:00.523569Z
## Translation job ID: a86d938d-fa65-424d-bf4e-0008985e1778
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_TBOS/Tables/TollPlus_TP_Customer_Addresses.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_TBOS.TollPlus_TP_Customer_Addresses
(
  custaddressid INT64 NOT NULL,
  customerid INT64 NOT NULL,
  addresstype STRING NOT NULL,
  addressline1 STRING NOT NULL,
  addressline2 STRING,
  addressline3 STRING,
  city STRING NOT NULL,
  state STRING NOT NULL,
  country STRING NOT NULL,
  zip1 STRING NOT NULL,
  zip2 STRING,
  isactive INT64 NOT NULL,
  iscommunication INT64 NOT NULL,
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
  action STRING,
  icnid INT64,
  channelid INT64,
  createddate DATETIME NOT NULL,
  createduser STRING,
  updateddate DATETIME NOT NULL,
  updateduser STRING,
  lnd_updatedate DATETIME,
  lnd_updatetype STRING,
  src_changedate DATETIME
)
cluster by custaddressid
;