## Translation time: 2024-03-04T06:44:00.523569Z
## Translation job ID: a86d938d-fa65-424d-bf4e-0008985e1778
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_TBOS/Tables/Stage_Agencies.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_TBOS_STAGE_FULL.IOP_Agencies
(
  agencyid INT64 NOT NULL,
  agencycode STRING,
  agencydesc STRING,
  rangeid INT64 NOT NULL,
  startfacilitycode INT64 NOT NULL,
  endfacilitycode INT64 NOT NULL,
  tagcount INT64 NOT NULL,
  customerid INT64,
  starthexid STRING,
  endhexid STRING,
  revcode STRING,
  encryptflag STRING,
  pgpkeyid STRING,
  ftpurl STRING,
  ftplogin STRING,
  ftppwd STRING,
  active STRING,
  createddate DATETIME NOT NULL,
  createduser STRING,
  updateddate DATETIME NOT NULL,
  updateuser STRING,
  lnd_updatedate DATETIME,
  lnd_updatetype STRING,
  src_changedate DATETIME
) cluster by agencyid
;