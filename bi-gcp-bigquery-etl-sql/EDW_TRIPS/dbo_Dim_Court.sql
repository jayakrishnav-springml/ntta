## Translation time: 2024-03-04T06:41:57.683170Z
## Translation job ID: 00dc6676-2c12-444a-b02a-71c7788bdc89
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/EDW_TRIPS/Tables/dbo_Dim_Court.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_TRIPS.Dim_Court
(
  courtid INT64 NOT NULL,
  countyid INT64 NOT NULL,
  courtname STRING NOT NULL,
  addressline1 STRING NOT NULL,
  addressline2 STRING,
  city STRING NOT NULL,
  state STRING NOT NULL,
  zip1 INT64 NOT NULL,
  zip2 INT64,
  starteffectivedate TIMESTAMP NOT NULL,
  endeffectivedate TIMESTAMP,
  precinctnumber STRING,
  placenumber STRING,
  telephonenumber STRING,
  lnd_updatedate TIMESTAMP,
  edw_updatedate DATETIME
)
CLUSTER BY courtid
;