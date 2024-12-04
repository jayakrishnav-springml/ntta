## Translation time: 2024-03-04T06:44:00.523569Z
## Translation job ID: a86d938d-fa65-424d-bf4e-0008985e1778
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_TBOS/Tables/TollPlus_TP_ImageReview.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_TBOS.TollPlus_TP_ImageReview
(
  imagereviewid INT64 NOT NULL,
  eventid INT64 NOT NULL,
  transactiondatetime DATETIME NOT NULL,
  plazaid INT64 NOT NULL,
  laneid INT64 NOT NULL,
  vehiclestate STRING,
  vehiclenumber STRING,
  vehicleclass STRING,
  tagid STRING,
  facilitycode STRING,
  statusid INT64 NOT NULL,
  statusdate DATETIME NOT NULL,
  reasoncode STRING,
  reviewtype INT64 NOT NULL,
  createddate DATETIME NOT NULL,
  createduser STRING,
  updateddate DATETIME NOT NULL,
  updateduser STRING,
  lnd_updatedate DATETIME,
  lnd_updatetype STRING,
  src_changedate DATETIME
)
cluster by imagereviewid
;