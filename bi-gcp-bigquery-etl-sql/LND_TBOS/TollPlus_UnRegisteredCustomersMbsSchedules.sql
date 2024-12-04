## Translation time: 2024-03-04T06:44:00.523569Z
## Translation job ID: a86d938d-fa65-424d-bf4e-0008985e1778
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_TBOS/Tables/TollPlus_UnRegisteredCustomersMbsSchedules.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_TBOS.TollPlus_UnRegisteredCustomersMbsSchedules
(
  unregmbsscheduleid INT64 NOT NULL,
  customerid INT64,
  vehicleid INT64,
  nextscheduledate DATETIME,
  lastmbsid INT64,
  licenseplatenumber STRING,
  statecode STRING,
  mbsgenstatus STRING,
  retryattempts INT64 NOT NULL,
  scheduleddate DATETIME,
  agencyid INT64,
  isimmediateflag INT64,
  isloadbalance INT64,
  createddate DATETIME NOT NULL,
  createduser STRING,
  updateddate DATETIME NOT NULL,
  updateduser STRING,
  lnd_updatedate DATETIME,
  lnd_updatetype STRING,
  src_changedate DATETIME
)
cluster by unregmbsscheduleid
;