## Translation time: 2024-03-04T06:44:00.523569Z
## Translation job ID: a86d938d-fa65-424d-bf4e-0008985e1778
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_TBOS/Tables/History_TP_Customer_Attributes.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_TBOS.History_TP_Customer_Attributes
(
  histid INT64 NOT NULL,
  customerid INT64 NOT NULL,
  driverlicencenumber STRING,
  driverlicenceapprovedstate STRING,
  driverlicenceexpirationdate DATETIME,
  autoreplenishmentid INT64,
  preferredshipment INT64,
  transponderpurchasemethod INT64,
  calculatedrebillamount NUMERIC(31, 2),
  thresholdamount NUMERIC(31, 2),
  ismanualhold INT64 NOT NULL,
  statementdeliveryoptionid INT64,
  sourceofchannelid INT64,
  rebill_hold_starteffectivedate DATETIME,
  rebill_hold_endeffectivedate DATETIME,
  is_notifications_added INT64 NOT NULL,
  capamount NUMERIC(31, 2),
  kycstatusid INT64,
  kycstatusdate DATETIME,
  statementcycleid INT64,
  rebillstatus STRING,
  rebilldate DATETIME,
  preferredlanguage STRING,
  ishearingimpairment INT64 NOT NULL,
  isfrequentcaller INT64 NOT NULL,
  issupervisor INT64 NOT NULL,
  tagsinstatusfile INT64 NOT NULL,
  invoiceintervalid INT64,
  invoiceamount NUMERIC(31, 2),
  invoiceday STRING,
  lowbalanceamount NUMERIC(31, 2),
  mbsgenerationday INT64,
  ssn STRING,
  is_commercial INT64 NOT NULL,
  iseventsponsor INT64 NOT NULL,
  isvip INT64 NOT NULL,
  ismilitary INT64 NOT NULL,
  autorecalcreplamt INT64 NOT NULL,
  nonrevenuetypeid INT64,
  istollperks INT64 NOT NULL,
  ismarketingandnewsletter INT64 NOT NULL,
  isdirectcarrierbilling INT64 NOT NULL,
  companycode STRING,
  isgroundtransportation INT64 NOT NULL,
  mbsimageid INT64,
  violatortypeid INT64,
  icnid INT64,
  channelid INT64,
  action STRING,
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