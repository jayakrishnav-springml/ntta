## Translation time: 2024-03-04T06:44:00.523569Z
## Translation job ID: a86d938d-fa65-424d-bf4e-0008985e1778
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_TBOS/Tables/Stage_Ref_FeeTypes.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_TBOS_STAGE_FULL.TollPlus_Ref_FeeTypes
(
  feetypeid INT64 NOT NULL,
  feename STRING,
  feecode STRING,
  feedescription STRING,
  feefactor STRING,
  amount NUMERIC(31, 2),
  starteffectivedate DATETIME,
  endeffectivedate DATETIME,
  isactive INT64 NOT NULL,
  appliedon_accountcreation INT64,
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

CLUSTER BY FeeTypeID
;