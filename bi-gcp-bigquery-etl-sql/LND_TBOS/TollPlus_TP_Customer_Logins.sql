## Translation time: 2024-03-04T06:44:00.523569Z
## Translation job ID: a86d938d-fa65-424d-bf4e-0008985e1778
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_TBOS/Tables/TollPlus_TP_Customer_Logins.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_TBOS.TollPlus_TP_Customer_Logins
(
  loginid INT64 NOT NULL,
  customerid INT64 NOT NULL,
  icnid INT64,
  channelid INT64,
  username STRING NOT NULL,
  password STRING NOT NULL,
  last_logindate DATETIME,
  last_pwd_modifieddate DATETIME,
  current_pwd_expirydate DATETIME,
  pwd_attempts_count INT64,
  pinnumber STRING,
  islocked INT64 NOT NULL,
  createddate DATETIME NOT NULL,
  createduser STRING NOT NULL,
  updateddate DATETIME NOT NULL,
  updateduser STRING NOT NULL,
  sq_attemptcount INT64,
  sq_lockouttime DATETIME,
  lockouttime DATETIME,
  lnd_updatedate DATETIME,
  lnd_updatetype STRING,
  src_changedate DATETIME
)
cluster by loginid
;