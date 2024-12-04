## Translation time: 2024-03-04T06:44:00.523569Z
## Translation job ID: a86d938d-fa65-424d-bf4e-0008985e1778
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_TBOS/Tables/Stage_TollPlus_Agencies.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_TBOS_STAGE_FULL.TollPlus_Agencies
(
  agencyid INT64 NOT NULL,
  agencytypeid INT64 NOT NULL,
  agencyname STRING,
  agencycode STRING NOT NULL,
  agencydesc STRING,
  ifsccode STRING,
  accounttype STRING,
  bankname STRING,
  accountname STRING,
  accountnumber STRING,
  rangeid INT64,
  startfacilitycode INT64,
  endfacilitycode INT64,
  tagcount INT64,
  customerid INT64,
  starthexid STRING,
  endhexid STRING,
  revcode STRING,
  encryptflag STRING,
  pgpkeyid STRING,
  ftpurl STRING,
  ftplogin STRING,
  ftppwd STRING,
  isactive INT64 NOT NULL,
  starteffectivedate DATETIME NOT NULL,
  endeffectivedate DATETIME NOT NULL,
  isswitchable INT64,
  protocoltype STRING,
  ishomeagency INT64,
  parentagencycode STRING,
  iopagencyid STRING,
  hubid STRING,
  tagagencyid STRING,
  channelid INT64,
  icnid INT64,
  createddate DATETIME NOT NULL,
  createduser STRING,
  updateddate DATETIME NOT NULL,
  updateduser STRING,
  lnd_updatedate DATETIME,
  lnd_updatetype STRING,
  src_changedate DATETIME
)Cluster by agencyid
;