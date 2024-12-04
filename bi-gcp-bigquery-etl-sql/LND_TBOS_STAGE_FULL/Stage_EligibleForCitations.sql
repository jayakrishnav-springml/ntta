## Translation time: 2024-03-04T06:44:00.523569Z
## Translation job ID: a86d938d-fa65-424d-bf4e-0008985e1778
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_TBOS/Tables/Stage_EligibleForCitations.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_TBOS_STAGE_FULL.TER_EligibleForCitations
(
  eligiblecitationid INT64 NOT NULL,
  accountnumber INT64 NOT NULL,
  name STRING,
  vehiclenumber STRING,
  vehiclemake STRING,
  vehiclemodel STRING,
  vehicleyear STRING,
  noofeligiblenotices INT64,
  totaloutstandingtolls INT64,
  firsteligibletxndate DATETIME,
  lasteligibletxndate DATETIME,
  coownerexists INT64,
  suffix STRING,
  isactive INT64,
  createddate DATETIME NOT NULL,
  createduser STRING NOT NULL,
  updateddate DATETIME NOT NULL,
  updateduser STRING NOT NULL,
  prvrefreshoptoutdate DATETIME,
  optoutdate DATETIME,
  lnd_updatedate DATETIME,
  lnd_updatetype STRING,
  src_changedate DATETIME
)
CLUSTER BY eligiblecitationid
;