## Translation time: 2024-03-04T06:44:00.523569Z
## Translation job ID: a86d938d-fa65-424d-bf4e-0008985e1778
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_TBOS/Tables/Stage_ParkingTrips.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_TBOS_STAGE_CDC.Parking_ParkingTrips
(
  recordcode STRING,
  referenceid INT64,
  entrytolltxnid INT64,
  entrytripdatetime DATETIME,
  entrytripdatetimeutc DATETIME,
  exittripdatetime DATETIME,
  exittripdatetimeutc DATETIME,
  entrylaneid INT64,
  entryplazaid INT64,
  exitlaneid INT64,
  exitplazaid INT64,
  sourcetripid INT64,
  internaldisposition STRING,
  externaldisposition STRING,
  entrytagstatus STRING,
  exittagstatus STRING,
  exittagstatuslistbatchid INT64,
  entrytagstatuslistbatchid INT64,
  entryrevenuetype INT64,
  exitrevenuetype INT64,
  tagid STRING,
  tagvehicleclassification INT64,
  tagagency STRING,
  tollamount NUMERIC(31, 2),
  procfeeflat NUMERIC(31, 2),
  procfeeflattype STRING,
  procfeepct NUMERIC(31, 2),
  procfeepcttype STRING,
  vendorfee NUMERIC(31, 2),
  surchargefeetype STRING,
  outstandingamount NUMERIC(31, 2),
  posteddate DATETIME,
  tripstageid INT64,
  tripstatusid INT64,
  tripstatusdate DATETIME,
  paymentstatusid INT64,
  guaranteed STRING,
  vendor STRING,
  agencyguesttype STRING,
  agencytransactiontype STRING,
  agencyhosttransactionid STRING,
  vehiclenumber STRING,
  vehicleid INT64,
  vehiclestate STRING,
  licenseplatecountry STRING,
  agencyid INT64,
  originatingagencyid INT64,
  reasoncode STRING,
  disposition STRING,
  tagagencyid INT64,
  attribute5 STRING,
  transactioncreateduser STRING,
  transactioncreateddate STRING,
  attribute8 STRING,
  attribute9 STRING,
  attribute10 STRING,
  processcount INT64,
  sourcepkid INT64,
  tptripid INT64 NOT NULL,
  exitlocationid INT64,
  sourcedisposition STRING,
  sourcereasoncode STRING,
  previousreasoncode STRING,
  isreprocessreceived INT64 NOT NULL,
  isreprocessedfeeapplied INT64 NOT NULL,
  receivedentrylocationcode STRING,
  receivedexitlocationcode STRING,
  createddate DATETIME NOT NULL,
  createduser STRING NOT NULL,
  updateddate DATETIME NOT NULL,
  updateduser STRING NOT NULL,
  lnd_updatedate DATETIME,
  lnd_updatetype STRING,
  src_changedate DATETIME
)
cluster by tptripid
;