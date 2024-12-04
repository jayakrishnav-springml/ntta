## Translation time: 2024-03-04T06:44:00.523569Z
## Translation job ID: a86d938d-fa65-424d-bf4e-0008985e1778
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_TBOS/Tables/dbo_CB_Amex_BadData.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_TBOS.dbo_CB_Amex_BadData
(
  monthid STRING,
  winlossstatus STRING,
  casenumber STRING,
  cardnumber STRING,
  senumber STRING,
  originalreasoncode STRING,
  originalreasoncodedescription STRING,
  chargereferencenumber STRING,
  chargebackstatus STRING,
  replybydate STRING,
  respondedondate STRING,
  cbdatereceived STRING,
  chargebackamount STRING,
  chargebackamountcurrencycode STRING,
  caseupdatedate STRING,
  caseupdateamount STRING,
  caseupdateamountcurrencycode STRING,
  adjustmentdate STRING,
  adjustmentnumber STRING,
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
  errorcode STRING,
  errorcolumn STRING,
  src_changedate DATETIME
)
;