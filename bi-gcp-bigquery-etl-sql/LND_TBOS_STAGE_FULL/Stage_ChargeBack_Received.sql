## Translation time: 2024-03-04T06:44:00.523569Z
## Translation job ID: a86d938d-fa65-424d-bf4e-0008985e1778
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_TBOS/Tables/Stage_ChargeBack_Received.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_TBOS_STAGE_FULL.dbo_ChargeBack_Received
(
  monthid INT64,
  entitylevel STRING,
  entityid INT64,
  statusflag STRING,
  sequencenumber INT64,
  transactiondivisionnumber INT64,
  merchantordernumber INT64,
  accountnumber STRING,
  reasoncode STRING,
  originaltransactiondate DATETIME,
  chargebackreceiveddate DATETIME,
  activitydate DATETIME,
  chargebackamount NUMERIC(31, 2),
  cbcycle STRING,
  lnd_updatedate DATETIME,
  src_changedate DATETIME
)
;