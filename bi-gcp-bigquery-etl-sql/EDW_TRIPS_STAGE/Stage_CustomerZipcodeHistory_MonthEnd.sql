## Translation time: 2024-03-13T05:19:34.327071Z
## Translation job ID: 0a711804-adbe-4db7-8cda-d8808bd4ce52
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/NTTA_Missing_DDLs/EDW_TRIPS_Stage_CustomerZipcodeHistory_MonthEnd.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_TRIPS_STAGE.CustomerZipcodeHistory_MonthEnd
(
  monthid INT64 NOT NULL,
  src STRING NOT NULL,
  customerid INT64 NOT NULL,
  zipcode STRING NOT NULL,
  updateddate DATETIME NOT NULL,
  rn INT64
)
cluster by customerid
;