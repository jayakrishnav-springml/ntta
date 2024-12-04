## Translation time: 2024-03-04T06:44:00.523569Z
## Translation job ID: a86d938d-fa65-424d-bf4e-0008985e1778
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_TBOS/Tables/CaseManager_PmCaseTypes.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_TBOS.CaseManager_PmCaseTypes
(
  casetypeid INT64 NOT NULL,
  casetype STRING NOT NULL,
  casetypedesc STRING,
  isvisible INT64,
  fetchapiurl STRING,
  parent_casetypeid INT64 NOT NULL,
  remarks STRING,
  casecreatednotificationtrigger INT64,
  visibleselfservicechannel INT64,
  customersurveytrigger INT64,
  caseclosurenotificationtrigger INT64,
  createduser STRING NOT NULL,
  createddate DATETIME NOT NULL,
  updateduser STRING,
  updateddate DATETIME,
  lnd_updatedate DATETIME,
  lnd_updatetype STRING,
  src_changedate DATETIME
)
CLUSTER BY
casetypeid
;