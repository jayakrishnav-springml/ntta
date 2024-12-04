## Translation time: 2024-03-04T06:44:00.523569Z
## Translation job ID: a86d938d-fa65-424d-bf4e-0008985e1778
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_TBOS/Tables/Stage_TP_ViolatedTripStatusTracker.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_TBOS_STAGE_FULL.TollPlus_TP_ViolatedTripStatusTracker
(
  statustrackerid INT64 NOT NULL,
  citationid INT64 NOT NULL,
  tptripid INT64 NOT NULL,
  violatorid INT64 NOT NULL,
  vehiclenumber STRING,
  tripstatusid INT64 NOT NULL,
  tripstatusdate DATETIME,
  citationstage STRING,
  citationtype STRING,
  tripstageid INT64,
  platetype STRING,
  createddate DATETIME NOT NULL,
  createduser STRING,
  updateddate DATETIME NOT NULL,
  updateduser STRING,
  lnd_updatedate DATETIME,
  lnd_updatetype STRING,
  src_changedate DATETIME
)Cluster by statustrackerid
;