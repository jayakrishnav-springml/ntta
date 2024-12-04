-- Translation time: 2024-06-04T08:06:27.696231Z
-- Translation job ID: a4465f30-9e78-4d9a-ad69-bbfb39271a9b
-- Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_TER/Tables/dbo_PaymentPlan.sql
-- Translated from: SqlServer
-- Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_TER.PaymentPlan
(
  paymentplanid INT64 NOT NULL,
  paymentplanstatuslookupid INT64 NOT NULL,
  activeagreementflag INT64 NOT NULL,
  activeagreementdate DATETIME,
  defaultedflag INT64 NOT NULL,
  defaulteddate DATETIME,
  paidinfullflag INT64 NOT NULL,
  paidinfulldate DATETIME,
  bankruptcyflag INT64 NOT NULL,
  bankruptcydate DATETIME,
  violationamt NUMERIC(33, 4) NOT NULL,
  zipcashamt NUMERIC(33, 4) NOT NULL,
  settlementamt NUMERIC(33, 4) NOT NULL,
  adminfeecount INT64 NOT NULL,
  adminfeetotal NUMERIC(33, 4) NOT NULL,
  citationcount INT64 NOT NULL,
  citationfeetotal NUMERIC(33, 4) NOT NULL,
  collectionsreceived NUMERIC(33, 4) NOT NULL,
  customdownpaymentreceivedflag INT64 NOT NULL,
  downpaymentreceived NUMERIC(33, 4) NOT NULL,
  totalreceived NUMERIC(33, 4) NOT NULL,
  remainingbalancedue NUMERIC(33, 4) NOT NULL,
  monthlypayment NUMERIC(33, 4) NOT NULL,
  lastpayment NUMERIC(33, 4) NOT NULL,
  customnoofmonthsflag INT64 NOT NULL,
  totalnoofmonths INT64 NOT NULL,
  firstnoofmonths INT64 NOT NULL,
  planstartdate DATETIME NOT NULL,
  firstpaymentdate DATETIME NOT NULL,
  lastpaymentdate DATETIME NOT NULL,
  paymentplanremedysourcelookupid INT64 NOT NULL,
  paymentplancontactsourcelookupid INT64 NOT NULL,
  spanishflag INT64,
  lastname STRING NOT NULL,
  firstname STRING,
  lastname2nd STRING,
  firstname2nd STRING,
  address1 STRING,
  address2 STRING,
  city STRING,
  statelookupid INT64 NOT NULL,
  zipcode STRING,
  plus4 STRING,
  phonenbr STRING,
  otherphonenbr STRING,
  email STRING,
  tolltagnbr STRING,
  totalpaymentsamt NUMERIC(33, 4) NOT NULL,
  balancedue NUMERIC(33, 4) NOT NULL,
  totalnoofpayments INT64 NOT NULL,
  deletedflag INT64 NOT NULL,
  createddate DATETIME NOT NULL,
  createdby STRING NOT NULL,
  updateddate DATETIME,
  updatedby STRING,
  last_update_type STRING NOT NULL,
  last_update_date DATETIME NOT NULL
)
;
