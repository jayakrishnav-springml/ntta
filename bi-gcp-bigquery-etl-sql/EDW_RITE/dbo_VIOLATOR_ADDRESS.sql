## Translation time: 2024-03-21T20:56:06.764423Z
## Translation job ID: e212c5d3-a7fa-4886-93b1-cb3be341e70a
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/EDW_RITE/Tables/dbo_VIOLATOR_ADDRESS.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_RITE.Violator_Address
(
  violator_id NUMERIC(29),
  violator_addr_seq INT64,
  address1 STRING,
  address2 STRING,
  city STRING,
  state STRING,
  zip_code STRING,
  plus4 STRING,
  addr_status STRING,
  insert_date DATETIME,
  last_update_date DATETIME
)
;
