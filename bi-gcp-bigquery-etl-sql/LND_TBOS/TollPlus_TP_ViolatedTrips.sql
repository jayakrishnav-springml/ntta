## Translation time: 2024-03-04T06:44:00.523569Z
## Translation job ID: a86d938d-fa65-424d-bf4e-0008985e1778
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_TBOS/Tables/TollPlus_TP_ViolatedTrips.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_TBOS.TollPlus_TP_ViolatedTrips
(
  citationid INT64 NOT NULL,
  tptripid INT64 NOT NULL,
  violatorid INT64 NOT NULL,
  vehiclenumber STRING NOT NULL,
  vehiclestate STRING,
  vehicleclass STRING,
  vehicleid INT64,
  tollamount NUMERIC(31, 2) NOT NULL,
  feeamounts NUMERIC(31, 2) NOT NULL,
  outstandingamount NUMERIC(31, 2) NOT NULL,
  citationstage STRING NOT NULL,
  citationtype STRING NOT NULL,
  entrylaneid INT64 NOT NULL,
  exitlaneid INT64 NOT NULL,
  entryplazaid INT64 NOT NULL,
  exitplazaid INT64 NOT NULL,
  tripstageid INT64,
  tripstatusid INT64 NOT NULL,
  tripstatusdate DATETIME,
  stagemodifieddate DATETIME,
  entrytripdatetime DATETIME,
  exittripdatetime DATETIME,
  paymentstatusid INT64,
  transactiontypeid INT64,
  platetype STRING,
  agencyid INT64,
  pbmtollamount NUMERIC(31, 2),
  avitollamount NUMERIC(31, 2),
  licenseplatecountry STRING,
  locationid INT64,
  custrefid INT64,
  isimmediateflag INT64,
  netamount NUMERIC(31, 2),
  sourceofentry INT64,
  accountagencyid INT64,
  acct_id INT64,
  violation_id INT64,
  violation_status STRING,
  isexcessivevtoll INT64 NOT NULL,
  transactionpostingtype STRING,
  iswriteoff INT64,
  writeoffdate DATETIME,
  writeoffamount NUMERIC(31, 2),
  createddate DATETIME NOT NULL,
  createduser STRING NOT NULL,
  updateddate DATETIME NOT NULL,
  updateduser STRING NOT NULL,
  posteddate DATETIME,
  lnd_updatedate DATETIME,
  lnd_updatetype STRING,
  src_changedate DATETIME
)
cluster by citationid
;