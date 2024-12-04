## Translation time: 2024-03-04T06:44:00.523569Z
## Translation job ID: a86d938d-fa65-424d-bf4e-0008985e1778
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_TBOS/Tables/Stage_Ref_LookupTypeCodes_Hierarchy.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_TBOS_STAGE_CDC.TollPlus_Ref_LookupTypeCodes_Hierarchy
(
  lookuptypecodeid INT64 NOT NULL,
  lookuptypecode STRING NOT NULL,
  lookuptypecodedesc STRING NOT NULL,
  parent_lookuptypecodeid INT64,
  is_available_foruse INT64,
  remarks STRING,
  createddate DATETIME NOT NULL,
  createduser STRING NOT NULL,
  updateddate DATETIME NOT NULL,
  updateduser STRING NOT NULL,
  lnd_updatedate DATETIME,
  lnd_updatetype STRING,
  src_changedate DATETIME
)
CLUSTER BY LookupTypeCodeID
;