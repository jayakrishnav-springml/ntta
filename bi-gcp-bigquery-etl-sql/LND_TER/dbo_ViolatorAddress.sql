-- Translation time: 2024-06-04T08:06:27.696231Z
-- Translation job ID: a4465f30-9e78-4d9a-ad69-bbfb39271a9b
-- Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_TER/Tables/dbo_ViolatorAddress.sql
-- Translated from: SqlServer
-- Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_TER.ViolatorAddress
(
  violatoraddressid INT64 NOT NULL,
  violatorid INT64 NOT NULL,
  vidseq INT64 NOT NULL,
  violatoraddresssourcelookupid INT64 NOT NULL,
  violatoraddressstatuslookupid INT64 NOT NULL,
  activeflag INT64 NOT NULL,
  confirmedflag INT64 NOT NULL,
  address1 STRING NOT NULL,
  address2 STRING,
  city STRING NOT NULL,
  statelookupid INT64 NOT NULL,
  zipcode STRING NOT NULL,
  plus4 STRING,
  createddate DATETIME NOT NULL,
  createdby STRING NOT NULL,
  updateddate DATETIME,
  updatedby STRING,
  last_update_type STRING NOT NULL,
  last_update_date DATETIME NOT NULL
)
;
