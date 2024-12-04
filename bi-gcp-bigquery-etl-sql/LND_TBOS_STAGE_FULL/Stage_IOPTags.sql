## Translation time: 2024-03-04T06:44:00.523569Z
## Translation job ID: a86d938d-fa65-424d-bf4e-0008985e1778
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_TBOS/Tables/Stage_IOPTags.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_TBOS_STAGE_FULL.IOP_IOPTags
(
  ioppkid INT64 NOT NULL,
  startdate DATETIME,
  enddate DATETIME,
  lastfilets DATETIME,
  updatets DATETIME,
  fileagencyid STRING,
  tagstatus STRING,
  tagtype STRING,
  discountplan STRING,
  discplanstartdate DATETIME,
  discplanenddate DATETIME,
  tagclass STRING,
  accountno INT64,
  fleetin STRING,
  startfileid INT64,
  endfileid INT64,
  tagagencyid STRING,
  tagserialnumber STRING,
  createddate DATETIME NOT NULL,
  createduser STRING,
  updateddate DATETIME NOT NULL,
  updateduser STRING,
  lnd_updatedate DATETIME,
  lnd_updatetype STRING,
  src_changedate DATETIME
)
CLUSTER BY
ioppkid
;