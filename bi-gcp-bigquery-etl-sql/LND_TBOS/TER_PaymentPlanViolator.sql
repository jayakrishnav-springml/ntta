## Translation time: 2024-03-04T06:44:00.523569Z
## Translation job ID: a86d938d-fa65-424d-bf4e-0008985e1778
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_TBOS/Tables/TER_PaymentPlanViolator.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_TBOS.TER_PaymentPlanViolator
(
  paymentplanviolatorid INT64 NOT NULL,
  violatorid INT64 NOT NULL,
  hvid INT64,
  paymentplanid INT64 NOT NULL,
  paymentplanviolatorseq INT64,
  hvflag INT64,
  mbsid INT64 NOT NULL,
  ppcustomerid INT64,
  createddate DATETIME,
  createduser STRING,
  updateddate DATETIME,
  updateduser STRING,
  lnd_updatedate DATETIME,
  lnd_updatetype STRING,
  src_changedate DATETIME
)
CLUSTER BY
paymentplanviolatorid
;