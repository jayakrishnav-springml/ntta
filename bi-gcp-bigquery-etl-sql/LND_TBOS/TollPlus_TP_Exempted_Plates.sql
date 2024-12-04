## Translation time: 2024-03-04T06:44:00.523569Z
## Translation job ID: a86d938d-fa65-424d-bf4e-0008985e1778
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_TBOS/Tables/TollPlus_TP_Exempted_Plates.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_TBOS.TollPlus_TP_Exempted_Plates
(
  qualifiedveteranid INT64 NOT NULL,
  vehiclenumber STRING,
  vehiclestate STRING,
  country STRING,
  make STRING,
  model STRING,
  color STRING,
  vehicleclass STRING,
  isactive INT64,
  exempted_type STRING,
  year INT64,
  agency STRING,
  starteffectivedate DATETIME,
  endeffectivedate DATETIME,
  processstatus STRING,
  createddate DATETIME NOT NULL,
  createduser STRING,
  updateddate DATETIME NOT NULL,
  updateduser STRING,
  lnd_updatedate DATETIME,
  lnd_updatetype STRING,
  src_changedate DATETIME
)
cluster by qualifiedveteranid
;