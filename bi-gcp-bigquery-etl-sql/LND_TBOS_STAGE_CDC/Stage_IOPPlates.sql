## Translation time: 2024-03-04T06:44:00.523569Z
## Translation job ID: a86d938d-fa65-424d-bf4e-0008985e1778
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_TBOS/Tables/Stage_IOPPlates.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_TBOS_STAGE_CDC.IOP_IOPPlates
(
  iopplatepkid INT64 NOT NULL,
  platestate STRING,
  platenumber STRING,
  platecountry STRING,
  platestatus STRING,
  lastfilets DATETIME,
  updatets DATETIME,
  startdate DATETIME,
  enddate DATETIME,
  platetype STRING,
  fileagencyid STRING,
  discountplan STRING,
  discplanstartdate DATETIME,
  discplanenddate DATETIME,
  accountno INT64,
  fleetin STRING,
  startfileid INT64,
  endfileid INT64,
  tagagencyid STRING,
  tagserialnumber STRING,
  vehicleclass INT64,
  createddate DATETIME NOT NULL,
  createduser STRING,
  updateddate DATETIME NOT NULL,
  updateduser STRING,
  lnd_updatedate DATETIME,
  lnd_updatetype STRING,
  src_changedate DATETIME
)
CLUSTER BY
iopplatepkid
;