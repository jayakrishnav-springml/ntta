## Translation time: 2024-03-04T06:44:00.523569Z
## Translation job ID: a86d938d-fa65-424d-bf4e-0008985e1778
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_TBOS/Tables/Stage_TP_AppLication_Parameters.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_TBOS_STAGE_CDC.TollPlus_TP_AppLication_Parameters
(
  parameterid INT64 NOT NULL,
  parameterkey STRING,
  parametername STRING,
  parametervalue STRING NOT NULL,
  parameterdesc STRING NOT NULL,
  measurementdesc STRING,
  configtype STRING,
  departmenttype STRING,
  datatype STRING,
  minlength INT64,
  maxlength INT64,
  allowedsplchars INT64,
  isspaceallowed INT64,
  regularexp STRING,
  starteffectivedate DATETIME NOT NULL,
  endeffectivedate DATETIME NOT NULL,
  iseditable INT64 NOT NULL,
  channelid INT64,
  icnid INT64,
  isactive INT64 NOT NULL,
  createddate DATETIME NOT NULL,
  createduser STRING,
  updateddate DATETIME NOT NULL,
  updateduser STRING,
  lnd_updatedate DATETIME,
  lnd_updatetype STRING,
  src_changedate DATETIME
)
CLUSTER BY ParameterID
;