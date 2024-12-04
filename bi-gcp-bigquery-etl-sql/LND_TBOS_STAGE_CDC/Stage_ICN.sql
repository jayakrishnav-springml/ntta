## Translation time: 2024-03-04T06:44:00.523569Z
## Translation job ID: a86d938d-fa65-424d-bf4e-0008985e1778
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_TBOS/Tables/Stage_ICN.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_TBOS_STAGE_CDC.TollPlus_ICN
(
  icnid INT64 NOT NULL,
  userid INT64 NOT NULL,
  cashamount NUMERIC(31, 2),
  checkamount NUMERIC(31, 2),
  creditamount NUMERIC(31, 2),
  moamount NUMERIC(31, 2),
  floatamount NUMERIC(31, 2),
  icnstatus STRING,
  isdayshiftclosed INT64,
  cashiercheckamount NUMERIC(31, 2),
  shiftstartdate DATETIME,
  shiftenddate DATETIME,
  locationid INT64,
  locationroleid INT64,
  retrycnt INT64 NOT NULL,
  stickertagscount INT64 NOT NULL,
  integratedtagscount INT64 NOT NULL,
  licenseplatetagscount INT64 NOT NULL,
  hardcasetagscount INT64 NOT NULL,
  shiftapprovalstatus STRING,
  shiftsubmitted INT64,
  reasoncode STRING,
  csrcashamount NUMERIC(31, 2),
  createddate DATETIME NOT NULL,
  createduser STRING,
  updateduser STRING,
  updateddate DATETIME NOT NULL,
  lnd_updatedate DATETIME,
  lnd_updatetype STRING,
  src_changedate DATETIME
)
CLUSTER BY 
icnid
;