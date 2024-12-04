## Translation time: 2024-03-04T06:44:00.523569Z
## Translation job ID: a86d938d-fa65-424d-bf4e-0008985e1778
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_TBOS/Tables/Stage_IOPTagAgencyMapping.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_TBOS_STAGE_CDC.TollPlus_IOPTagAgencyMapping
(
  nttatagagencyid STRING,
  ioptagagencyid STRING,
  homeagencyid STRING,
  internaltagprefix STRING,
  hubid STRING,
  iophomeagencyid STRING,
  tid INT64 NOT NULL,
  hextagid STRING,
  agency STRING,
  agencyname STRING,
  ishomeagency INT64,
  isdisplayfromapplication INT64,
  isexitdatetimewithtz INT64 NOT NULL,
  imiparentagency STRING,
  createddate DATETIME,
  createduser STRING,
  updateddate DATETIME,
  updateduser STRING,
  lnd_updatedate DATETIME,
  lnd_updatetype STRING,
  src_changedate DATETIME
)
CLUSTER BY
tid
;