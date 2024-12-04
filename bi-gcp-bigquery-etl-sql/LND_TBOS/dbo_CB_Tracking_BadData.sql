## Translation time: 2024-03-04T06:44:00.523569Z
## Translation job ID: a86d938d-fa65-424d-bf4e-0008985e1778
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_TBOS/Tables/dbo_CB_Tracking_BadData.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_TBOS.dbo_CB_Tracking_BadData
(
  monthid STRING,
  sequencenumber STRING,
  amexcasenumber STRING,
  customername STRING,
  orderidnumber STRING,
  cardtype STRING,
  lastfourofcc STRING,
  disputecode STRING,
  amountdisputed STRING,
  prepaidaccount STRING,
  postpaidaccount STRING,
  zipcashinvoices STRING,
  caseowner STRING,
  receivedbyntta STRING,
  datereplied STRING,
  transactiondate STRING,
  tsadays STRING,
  howpaymentwasmade STRING,
  currentdisputestatus STRING,
  comments STRING,
  notes STRING,
  winlostsupervisorreview STRING,
  datereviewed STRING,
  reversalcasenumber STRING,
  casedate  STRING,
  date_case_approved STRING,
  managerreview STRING,
  airport STRING,
  lnd_updatedate DATETIME,
  `dc amountdisputed` STRING,
  `dc transactiondate` STRING,
  errorcode STRING,
  errorcolumn STRING,
  src_changedate DATETIME
)
;