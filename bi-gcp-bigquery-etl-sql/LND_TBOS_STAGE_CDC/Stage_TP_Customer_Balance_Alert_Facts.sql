## Translation time: 2024-03-04T06:44:00.523569Z
## Translation job ID: a86d938d-fa65-424d-bf4e-0008985e1778
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_TBOS/Tables/Stage_TP_Customer_Balance_Alert_Facts.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_TBOS_STAGE_CDC.TollPlus_TP_Customer_Balance_Alert_Facts
(
  customerid INT64 NOT NULL,
  lowbalanceflag INT64,
  lowbalancedate DATETIME,
  negbalanceflag INT64,
  negbalancedate DATETIME,
  lowbalancenotice INT64,
  negativebalancenotice INT64,
  sentemailcount INT64,
  regionalioplowbalanceflag INT64,
  regionalioplowbalancedate DATETIME,
  nationalioplowbalanceflag INT64,
  nationalioplowbalancedate DATETIME,
  accountfinancialstatus STRING,
  balanceflag INT64 NOT NULL,
  balancenotice INT64 NOT NULL,
  balancedate DATETIME,
  createddate DATETIME NOT NULL,
  createduser STRING,
  updateddate DATETIME NOT NULL,
  updateduser STRING,
  lnd_updatedate DATETIME,
  lnd_updatetype STRING,
  src_changedate DATETIME
)
CLUSTER BY CustomerID
;