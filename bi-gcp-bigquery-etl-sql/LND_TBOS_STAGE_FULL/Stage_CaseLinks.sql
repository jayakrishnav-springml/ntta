## Translation time: 2024-03-04T06:44:00.523569Z
## Translation job ID: a86d938d-fa65-424d-bf4e-0008985e1778
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_TBOS/Tables/Stage_CaseLinks.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_TBOS_STAGE_FULL.TollPlus_CaseLinks
(
  caselinkid INT64 NOT NULL,
  caseid INT64 NOT NULL,
  linkid INT64 NOT NULL,
  linksource STRING,
  casestatus INT64,
  remarks STRING,
  linkstatus STRING,
  imagereviewstatus STRING,
  createduser STRING NOT NULL,
  createddate DATETIME NOT NULL,
  updateduser STRING,
  updateddate DATETIME,
  lnd_updatedate DATETIME,
  lnd_updatetype STRING,
  src_changedate DATETIME
) cluster by caselinkid
;