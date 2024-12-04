-- Translation time: 2024-06-04T08:06:27.696231Z
-- Translation job ID: a4465f30-9e78-4d9a-ad69-bbfb39271a9b
-- Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_TER/Tables/dbo_Bankruptcy.sql
-- Translated from: SqlServer
-- Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_TER.Bankruptcy
(
  `violator id` FLOAT64 NOT NULL,
  seqnbr INT64 NOT NULL,
  bankruptcyinstancenbr INT64 NOT NULL,
  `last name` STRING,
  `first name` STRING,
  `last name2` STRING,
  `first name2` STRING,
  `license plate` STRING,
  `case number` STRING,
  `date notified` DATETIME,
  `filing date` DATETIME,
  `conversion date` DATETIME,
  `excused amount` NUMERIC(33, 4),
  `collectable amount` NUMERIC(33, 4),
  `phone number` STRING,
  `discharge _u002f_ dismissed` STRING,
  `discharge _u002f_ dismissed date` DATETIME,
  assets INT64 NOT NULL,
  `collection accounts` INT64 NOT NULL,
  `law firm` STRING,
  `attorney name` STRING,
  `claim filled` INT64 NOT NULL,
  comments STRING,
  `filing status` STRING,
  discharge_u002f_dismissed STRING,
  violatorid2 INT64,
  seqnbr2 INT64,
  violatorid3 INT64,
  seqnbr3 INT64,
  violatorid4 INT64,
  seqnbr4 INT64,
  insertdatetime DATETIME NOT NULL,
  insertbyuser STRING NOT NULL,
  lastupdatedatetime DATETIME,
  lastupdatebyuser STRING,
  last_update_type STRING NOT NULL,
  last_update_date DATETIME NOT NULL,
  tolls NUMERIC(33, 4),
  adminfees NUMERIC(33, 4),
  citation STRING
)
;
