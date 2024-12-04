## Translation time: 2024-03-04T06:44:00.523569Z
## Translation job ID: a86d938d-fa65-424d-bf4e-0008985e1778
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_TBOS/Tables/TER_HabitualViolators.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_TBOS.TER_HabitualViolators
(
  hvid INT64 NOT NULL,
  violatorid INT64 NOT NULL,
  hvseq INT64 NOT NULL,
  hvenabled INT64 NOT NULL,
  vehicleid INT64,
  affidavittype STRING,
  ishold INT64 NOT NULL,
  hvdesignationdate DATETIME,
  hvterminationdate DATETIME,
  hvterminationreason STRING,
  hvfirstqualifiedtrandate DATETIME,
  hvlastqualifiedtrandate DATETIME,
  hvqualifiedtrancount INT64,
  hvqualifiedamountdue NUMERIC(31, 2),
  hvqualifiedtollsdue NUMERIC(31, 2),
  hvqualifiedfeesdue NUMERIC(31, 2),
  hvqualifiedpenalitiesdue NUMERIC(31, 2),
  totalamountdue NUMERIC(31, 2),
  totaltollsdue NUMERIC(31, 2),
  totalfeesdue NUMERIC(31, 2),
  totaltrancount INT64,
  totalcitationcount INT64,
  adminhearingcounty STRING,
  vehicleregistrationcounty STRING,
  rovaddresscounty STRING,
  jobrundate DATETIME,
  currentstatuscode STRING,
  createduser STRING,
  createddate DATETIME,
  updateduser STRING,
  updateddate DATETIME,
  lnd_updatedate DATETIME,
  lnd_updatetype STRING,
  src_changedate DATETIME
)
CLUSTER BY
hvid
;