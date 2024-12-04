## Translation time: 2024-03-04T06:44:00.523569Z
## Translation job ID: a86d938d-fa65-424d-bf4e-0008985e1778
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_TBOS/Tables/TollPlus_CustomerFlagReferenceLookup.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_TBOS.TollPlus_CustomerFlagReferenceLookup
(
  customerflagreferenceid INT64 NOT NULL,
  flagname STRING,
  flagdescription STRING,
  isactive INT64,
  createddate DATETIME NOT NULL,
  createduser STRING NOT NULL,
  updateddate DATETIME,
  updateduser STRING,
  lnd_updatedate DATETIME,
  lnd_updatetype STRING,
  src_changedate DATETIME
)
CLUSTER BY CustomerFlagReferenceID
;