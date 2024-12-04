-- Translation time: 2024-06-04T08:06:27.696231Z
-- Translation job ID: a4465f30-9e78-4d9a-ad69-bbfb39271a9b
-- Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_TER/Tables/dbo_PaymentAgreement.sql
-- Translated from: SqlServer
-- Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_TER.PaymentAgreement
(
  `violator id` FLOAT64 NOT NULL,
  seqnbr INT64 NOT NULL,
  paymentplaninstancenbr INT64 NOT NULL,
  `last name` STRING,
  `first name` STRING,
  `phone number` STRING,
  `license plate` STRING,
  state STRING,
  `agent id` INT64,
  indicator STRING,
  `settlement amount` NUMERIC(33, 4),
  `down payment` NUMERIC(33, 4),
  `due date` DATETIME,
  `agreement type` STRING,
  `todays date` DATETIME,
  collections NUMERIC(33, 4),
  `remaining balance due` STRING,
  `payment plan due date` DATETIME,
  `check number` STRING,
  `paid in full` STRING NOT NULL,
  `default` STRING NOT NULL,
  `spanish only` INT64 NOT NULL,
  `amnesty account` INT64 NOT NULL,
  comments STRING,
  tolltag_acct_id NUMERIC(29),
  adminfees NUMERIC(33, 4),
  citationfees NUMERIC(33, 4),
  `monthly payment amount` NUMERIC(33, 4),
  defaultdate DATE,
  maintenanceagency STRING,
  violatorid2 INT64,
  seqnbr2 INT64,
  violatorid3 INT64,
  seqnbr3 INT64,
  violatorid4 INT64,
  seqnbr4 INT64,
  balancedue NUMERIC(33, 4),
  ntta_collections NUMERIC(33, 4),
  insertdatetime DATETIME NOT NULL,
  insertbyuser STRING NOT NULL,
  lastupdatedatetime DATETIME,
  lastupdatebyuser STRING,
  address1 STRING,
  address2 STRING,
  adminfeecount INT64,
  citationcount INT64,
  city STRING,
  email STRING,
  hvflag1 INT64,
  hvflag2 INT64,
  hvflag3 INT64,
  hvflag4 INT64,
  hvflag5 INT64,
  hvflag6 INT64,
  hvflag7 INT64,
  hvflag8 INT64,
  lastinvoicenbr1 STRING,
  lastinvoicenbr2 STRING,
  lastinvoicenbr3 STRING,
  lastinvoicenbr4 STRING,
  lastinvoicenbr5 STRING,
  lastinvoicenbr6 STRING,
  lastinvoicenbr7 STRING,
  lastinvoicenbr8 STRING,
  lastpayment NUMERIC(33, 4),
  licenseplatenbr2 STRING,
  licenseplatenbr3 STRING,
  licenseplatenbr4 STRING,
  licenseplatenbr5 STRING,
  licenseplatenbr6 STRING,
  licenseplatenbr7 STRING,
  licenseplatenbr8 STRING,
  licplatestate1 STRING,
  licplatestate2 STRING,
  licplatestate3 STRING,
  licplatestate4 STRING,
  licplatestate5 STRING,
  licplatestate6 STRING,
  licplatestate7 STRING,
  licplatestate8 STRING,
  otherphonenbr STRING,
  seqnbr5 INT64,
  seqnbr6 INT64,
  seqnbr7 INT64,
  seqnbr8 INT64,
  tolltagnbr STRING,
  totalnoofmonths INT64,
  totalreceived NUMERIC(33, 4),
  totalviolationamt NUMERIC(33, 4),
  totalzipcashamt NUMERIC(33, 4),
  vehiclemake1 STRING,
  vehiclemake2 STRING,
  vehiclemake3 STRING,
  vehiclemake4 STRING,
  vehiclemake5 STRING,
  vehiclemake6 STRING,
  vehiclemake7 STRING,
  vehiclemake8 STRING,
  vehiclemodel1 STRING,
  vehiclemodel2 STRING,
  vehiclemodel3 STRING,
  vehiclemodel4 STRING,
  vehiclemodel5 STRING,
  vehiclemodel6 STRING,
  vehiclemodel7 STRING,
  vehiclemodel8 STRING,
  vehicleyear1 INT64,
  vehicleyear2 INT64,
  vehicleyear3 INT64,
  vehicleyear4 INT64,
  vehicleyear5 INT64,
  vehicleyear6 INT64,
  vehicleyear7 INT64,
  vehicleyear8 INT64,
  violatorid5 INT64,
  violatorid6 INT64,
  violatorid7 INT64,
  violatorid8 INT64,
  zip STRING,
  contactsource STRING,
  paymentplanstatus STRING,
  last_update_type STRING NOT NULL,
  last_update_date DATETIME NOT NULL
)
;
