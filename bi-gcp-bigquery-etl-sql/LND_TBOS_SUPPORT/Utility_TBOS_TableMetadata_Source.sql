## Translation time: 2024-03-04T06:44:00.523569Z
## Translation job ID: a86d938d-fa65-424d-bf4e-0008985e1778
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_TBOS/Tables/Utility_TBOS_TableMetadata_Source.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_TBOS_SUPPORT.TBOS_TableMetadata_Source
(
  tableid INT64 NOT NULL,
  databasename STRING NOT NULL,
  schemaname STRING NOT NULL,
  tablename STRING NOT NULL,
  fullname STRING NOT NULL,
  distributionstring STRING,
  indexcolumns STRING,
  columnname STRING,
  columnid INT64,
  columnnullable INT64,
  columntype STRING
)
;