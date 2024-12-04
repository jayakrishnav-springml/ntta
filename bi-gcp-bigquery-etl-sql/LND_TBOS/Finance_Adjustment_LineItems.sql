## Translation time: 2024-03-04T06:44:00.523569Z
## Translation job ID: a86d938d-fa65-424d-bf4e-0008985e1778
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_TBOS/Tables/Finance_Adjustment_LineItems.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_TBOS.Finance_Adjustment_LineItems
(
  adjlineitemid INT64 NOT NULL,
  adjustmentid INT64 NOT NULL,
  amount NUMERIC(31, 2) NOT NULL,
  apptxntypecode STRING,
  linkid INT64,
  linksourcename STRING,
  newtollamount NUMERIC(31, 2),
  vehicleclass STRING,
  laneid INT64,
  isvisible INT64 NOT NULL,
  createddate DATETIME NOT NULL,
  createduser STRING,
  updateddate DATETIME NOT NULL,
  updateduser STRING,
  lnd_updatedate DATETIME,
  lnd_updatetype STRING,
  src_changedate DATETIME
)
CLUSTER BY
adjlineitemid
;