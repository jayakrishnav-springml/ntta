## Translation time: 2024-03-04T06:44:00.523569Z
## Translation job ID: a86d938d-fa65-424d-bf4e-0008985e1778
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_TBOS/Tables/Stage_Mbsheader.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_TBOS_STAGE_CDC.TollPlus_Mbsheader
(
  mbsid INT64 NOT NULL,
  mbsgenerateddate DATETIME NOT NULL,
  ispresentmbs INT64 NOT NULL,
  startperiod DATETIME,
  endperiod DATETIME,
  duedate DATETIME,
  customerid INT64,
  vehicleid INT64,
  vehiclestate STRING,
  previousdue NUMERIC(31, 2),
  amountpaid NUMERIC(31, 2),
  adjustments NUMERIC(31, 2),
  currentchargestoll NUMERIC(31, 2),
  currentchargesfee NUMERIC(31, 2),
  totalamount NUMERIC(31, 2),
  plateimagepath STRING,
  pdfpath STRING,
  mailingdate DATETIME,
  mailreturndate DATETIME,
  emaileddate DATETIME,
  emailreturndate DATETIME,
  newduedate DATETIME,
  sourcepkid INT64,
  mbsstatusid INT64 NOT NULL,
  qacategory STRING NOT NULL,
  platefilepathconfigurationid INT64,
  createddate DATETIME,
  createduser STRING,
  updateddate DATETIME,
  updateduser STRING,
  lnd_updatedate DATETIME,
  lnd_updatetype STRING,
  src_changedate DATETIME
)
cluster by mbsid
;