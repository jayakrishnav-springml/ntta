## Translation time: 2024-03-04T06:44:00.523569Z
## Translation job ID: a86d938d-fa65-424d-bf4e-0008985e1778
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_TBOS/Tables/Stage_ChargeBack_Tracking.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_TBOS_STAGE_CDC.dbo_ChargeBack_Tracking
(
  monthid INT64,
  sequencenumber STRING,
  amexcasenumber STRING,
  customername STRING,
  orderidnumber INT64,
  cardtype STRING,
  lastfourofcc STRING,
  disputecode STRING,
  amountdisputed STRING,
  prepaidaccount STRING,
  postpaidaccount STRING,
  zipcashinvoices STRING,
  caseowner STRING,
  receivedbyntta DATETIME,
  datereplied DATETIME,
  transactiondate STRING,
  tsadays INT64,
  howpaymentwasmade STRING,
  currentdisputestatus STRING,
  comments STRING,
  notes STRING,
  winlostsupervisorreview STRING,
  datereviewed DATETIME,
  reversalcasenumber STRING,
  casedate STRING,
  datecaseapproved STRING,
  managerreview STRING,
  airport STRING,
  lnd_updatedate DATETIME,
  src_changedate DATETIME
)

;