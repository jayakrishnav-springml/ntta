## Translation time: 2024-03-04T06:44:00.523569Z
## Translation job ID: a86d938d-fa65-424d-bf4e-0008985e1778
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_TBOS/Tables/Stage_Courts.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_TBOS_STAGE_CDC.Court_Courts
(
  courtid INT64 NOT NULL,
  countyid INT64 NOT NULL,
  courtname STRING NOT NULL,
  addressline1 STRING NOT NULL,
  addressline2 STRING,
  city STRING NOT NULL,
  state STRING NOT NULL,
  zip1 STRING NOT NULL,
  zip2 STRING,
  starteffectivedate DATETIME NOT NULL,
  endeffectivedate DATETIME,
  precinctnumber STRING,
  placenumber STRING,
  telephonenumber STRING,
  createddate DATETIME NOT NULL,
  createduser STRING NOT NULL,
  updateddate DATETIME NOT NULL,
  updateduser STRING NOT NULL,
  lnd_updatedate DATETIME,
  lnd_updatetype STRING,
  src_changedate DATETIME
)
CLUSTER BY courtid
;