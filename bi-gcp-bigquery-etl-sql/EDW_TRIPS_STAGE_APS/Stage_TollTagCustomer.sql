## Translation time: 2024-03-13T05:19:34.327071Z
## Translation job ID: 0a711804-adbe-4db7-8cda-d8808bd4ce52
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/NTTA_Missing_DDLs/EDW_TRIPS_Stage_TollTagCustomer.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_TRIPS_STAGE_APS.TollTagCustomer
(
  customerid INT64 NOT NULL,
  accounttypeid INT64 NOT NULL,
  accounttypedesc STRING NOT NULL,
  accountstatusid INT64 NOT NULL,
  accountstatusdesc STRING NOT NULL,
  accountstatusdate DATE NOT NULL,
  autoreplenishmentid INT64 NOT NULL,
  autoreplenishmentcode STRING NOT NULL,
  rebillamount NUMERIC(31, 2) NOT NULL,
  rebillamountgroupid INT64,
  zipcode STRING,
  accountcreatedate DATETIME,
  accountlastclosedate DATETIME
)
cluster by customerid
;