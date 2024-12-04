## Translation time: 2024-03-04T06:44:00.523569Z
## Translation job ID: a86d938d-fa65-424d-bf4e-0008985e1778
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_TBOS/Tables/Court_AdminHearing.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_TBOS.Court_AdminHearing
(
  adminhearingid INT64 NOT NULL,
  hvid INT64 NOT NULL,
  vioaffidavitid INT64,
  judgeid INT64,
  causeno STRING,
  hvstatuslookupid INT64 NOT NULL,
  hearingdate DATETIME,
  countyid INT64,
  requesteddate DATETIME NOT NULL,
  hearingreason STRING,
  comments STRING,
  createddate DATETIME NOT NULL,
  createduser STRING NOT NULL,
  updateddate DATETIME NOT NULL,
  updateduser STRING NOT NULL,
  lnd_updatedate DATETIME,
  lnd_updatetype STRING,
  src_changedate DATETIME
)
CLUSTER BY 
adminhearingid
;