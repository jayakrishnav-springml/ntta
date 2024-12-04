## Translation time: 2024-03-04T06:44:00.523569Z
## Translation job ID: a86d938d-fa65-424d-bf4e-0008985e1778
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_TBOS/Tables/Stage_Image_Storage_Paths.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_TBOS_STAGE_FULL.EIP_Image_Storage_Paths
(
  pathid STRING COLLATE '' NOT NULL ,
  agencycode STRING COLLATE '' NOT NULL,
  storagetype INT64 NOT NULL,
  imagetype STRING NOT NULL,
  pathname STRING NOT NULL,
  virtualpath STRING NOT NULL,
  sharedpath STRING,
  createddate DATETIME NOT NULL,
  updateduser STRING NOT NULL,
  updateddate DATETIME NOT NULL,
  lnd_updatedate DATETIME,
  lnd_updatetype STRING,
  src_changedate DATETIME
)
CLUSTER BY
pathid, agencycode,storagetype
;