## Translation time: 2024-03-04T06:44:00.523569Z
## Translation job ID: a86d938d-fa65-424d-bf4e-0008985e1778
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_TBOS/Tables/Stage_Overpayments.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_TBOS_STAGE_FULL.Finance_Overpayments
(
  overpaymentid INT64 NOT NULL,
  customerid INT64,
  linkid INT64,
  linksourcename STRING,
  overpaymentamount NUMERIC(31, 2),
  amountused NUMERIC(31, 2),
  remainingamount NUMERIC(31, 2),
  createduser STRING,
  createddate DATETIME,
  updateduser STRING,
  updateddate DATETIME,
  tripadjustmentid INT64,
  lnd_updatedate DATETIME,
  lnd_updatetype STRING,
  src_changedate DATETIME
)
cluster by overpaymentid
;