## Translation time: 2024-03-04T06:44:00.523569Z
## Translation job ID: a86d938d-fa65-424d-bf4e-0008985e1778
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_TBOS/Tables/Stage_TP_Customer_Internal_Users.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_TBOS_STAGE_FULL.TollPlus_TP_Customer_Internal_Users
(
  customerid INT64 NOT NULL,
  usertypeid INT64 NOT NULL,
  username STRING,
  password STRING,
  isactive INT64,
  isdomainaccount INT64,
  themes STRING,
  languages STRING,
  last_logindate DATETIME,
  last_pwd_modifieddate DATETIME,
  current_pwd_expirydate DATETIME,
  pwd_attempts_count INT64,
  islocked INT64,
  lockouttime DATETIME,
  locationcode STRING,
  employeeid STRING,
  starteffectivedate DATETIME,
  endeffectivedate DATETIME,
  terminateddate DATETIME,
  isloginverificationrequired INT64 NOT NULL,
  emailaddress STRING,
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
CLUSTER BY CustomerID
;