## Translation time: 2024-03-04T06:44:00.523569Z
## Translation job ID: a86d938d-fa65-424d-bf4e-0008985e1778
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_TBOS/Tables/TER_HVStatusLookup.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_TBOS.TER_HVStatusLookup
(
  hvstatuslookupid INT64 NOT NULL,
  statuscode STRING NOT NULL,
  statusdescription STRING,
  parentstatusid INT64,
  isactive INT64 NOT NULL,
  detaileddesc STRING,
  createddate DATETIME,
  createduser STRING,
  updateddate DATETIME,
  updateduser STRING,
  lnd_updatedate DATETIME,
  lnd_updatetype STRING,
  src_changedate DATETIME
)
CLUSTER BY
hvstatuslookupid
;