## Translation time: 2024-03-04T06:44:00.523569Z
## Translation job ID: a86d938d-fa65-424d-bf4e-0008985e1778
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_TBOS/Tables/TollPlus_Plans.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_TBOS.TollPlus_Plans
(
  planid INT64 NOT NULL,
  planname STRING,
  plancode STRING,
  plandescription STRING,
  parentid INT64 NOT NULL,
  isfeerequired INT64 NOT NULL,
  istagrequired INT64 NOT NULL,
  statementcycleid INT64,
  starteffectivedate DATETIME NOT NULL,
  endeffectivedate DATETIME NOT NULL,
  invoiceintervalid INT64,
  createddate DATETIME NOT NULL,
  createduser STRING,
  updateddate DATETIME NOT NULL,
  updateduser STRING,
  lnd_updatedate DATETIME,
  lnd_updatetype STRING,
  src_changedate DATETIME
)
CLUSTER BY PlanID
;