## Translation time: 2024-03-04T06:44:00.523569Z
## Translation job ID: a86d938d-fa65-424d-bf4e-0008985e1778
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_TBOS/Tables/Stage_History_TP_Customers.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_TBOS_STAGE_FULL.History_TP_Customers
(
  histid INT64 NOT NULL,
  customerid INT64 NOT NULL,
  usertypeid INT64,
  customerstatusid INT64,
  accountstatusid INT64 NOT NULL,
  accountstatusdate DATETIME,
  parentcustomerid INT64,
  sourceofentry INT64,
  revenuecategoryid INT64 NOT NULL,
  isprimary INT64,
  sourcepkid INT64,
  action STRING,
  agencyid INT64,
  regcustrefid INT64,
  icnid INT64,
  channelid INT64,
  createddate DATETIME NOT NULL,
  createduser STRING,
  updateddate DATETIME NOT NULL,
  updateduser STRING,
  lnd_updatedate DATETIME,
  lnd_updatetype STRING,
  src_changedate DATETIME
)
CLUSTER BY
histid
;