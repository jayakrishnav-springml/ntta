## Translation time: 2024-03-04T06:44:00.523569Z
## Translation job ID: a86d938d-fa65-424d-bf4e-0008985e1778
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_TBOS/Tables/Stage_Escheatment_Elgible_Customers.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_TBOS_STAGE_FULL.TollPlus_Escheatment_Elgible_Customers
(
  escheatmentid INT64 NOT NULL,
  customerid INT64,
  accountstatusid INT64,
  esstatusid INT64,
  esstatusdate DATETIME,
  amount NUMERIC(31, 2),
  linkid INT64,
  linksourcename STRING,
  sourceofentry STRING,
  adjustmentid INT64,
  firstname STRING,
  middlename STRING,
  lastname STRING,
  receivedcheckid INT64,
  fromdate DATETIME,
  createduser STRING,
  createddate DATETIME,
  updateduser STRING,
  updateddate DATETIME,
  lnd_updatedate DATETIME,
  lnd_updatetype STRING,
  src_changedate DATETIME
)
CLUSTER BY escheatmentid
;