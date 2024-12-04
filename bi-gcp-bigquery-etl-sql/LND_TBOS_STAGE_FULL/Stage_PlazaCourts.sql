## Translation time: 2024-03-04T06:44:00.523569Z
## Translation job ID: a86d938d-fa65-424d-bf4e-0008985e1778
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_TBOS/Tables/Stage_PlazaCourts.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_TBOS_STAGE_FULL.Court_PlazaCourts
(
  plazacourtid INT64 NOT NULL,
  plazaid INT64 NOT NULL,
  courtid INT64 NOT NULL,
  milemarker INT64,
  isactive INT64 NOT NULL,
  createddate DATETIME NOT NULL,
  createduser STRING NOT NULL,
  updateddate DATETIME NOT NULL,
  updateduser STRING NOT NULL,
  lnd_updatedate DATETIME,
  lnd_updatetype STRING,
  src_changedate DATETIME
)
cluster by plazacourtid
;