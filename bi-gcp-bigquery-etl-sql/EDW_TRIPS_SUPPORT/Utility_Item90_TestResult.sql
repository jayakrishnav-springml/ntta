## Translation time: 2024-03-04T06:41:57.683170Z
## Translation job ID: 00dc6676-2c12-444a-b02a-71c7788bdc89
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/EDW_TRIPS/Tables/Utility_Item90_TestResult.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_TRIPS_SUPPORT.Item90_TestResult
(
  testdate DATETIME NOT NULL,
  testrunid INT64 NOT NULL,
  testcaseid NUMERIC(32, 3) NOT NULL,
  testcasedesc STRING,
  testresultdesc STRING,
  teststatus STRING,
  invoicecount INT64,
  sampleinvoicenumber INT64,
  datacategory STRING,
  edw_updatedate DATETIME NOT NULL
)
cluster by testdate
;