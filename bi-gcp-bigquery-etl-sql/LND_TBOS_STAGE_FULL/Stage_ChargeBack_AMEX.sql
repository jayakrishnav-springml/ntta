## Translation time: 2024-03-04T06:44:00.523569Z
## Translation job ID: a86d938d-fa65-424d-bf4e-0008985e1778
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_TBOS/Tables/Stage_ChargeBack_AMEX.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_TBOS_STAGE_FULL.dbo_ChargeBack_AMEX
(
  monthid INT64,
  winlossstatus STRING,
  casenumber STRING,
  cardnumber STRING,
  senumber INT64,
  originalreasoncode STRING,
  originalreasoncodedescription STRING,
  chargereferencenumber INT64,
  chargebackstatus STRING,
  replybydate DATETIME,
  respondedondate DATETIME,
  cbdatereceived DATETIME,
  chargebackamount STRING,
  chargebackamountcurrencycode STRING,
  caseupdatedate DATETIME,
  caseupdateamount STRING,
  caseupdateamountcurrencycode STRING,
  adjustmentdate DATETIME,
  adjustmentnumber INT64,
  chargeamount STRING,
  chargeamountcurrency STRING,
  disputeamount STRING,
  disputeamountcurrencycode STRING,
  casenote STRING,
  merchantinitials STRING,
  responsenotes STRING,
  casecurrentstatus STRING,
  updatedreasoncode STRING,
  updatedreasoncodedescription STRING,
  lnd_updatedate DATETIME,
  src_changedate DATETIME
)

;