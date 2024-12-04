## Translation time: 2024-03-21T20:56:06.764423Z
## Translation job ID: e212c5d3-a7fa-4886-93b1-cb3be341e70a
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/EDW_RITE/Tables/dbo_VIOLATOR_ADDRESS_MAX_SEQ.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_RITE.Violator_Address_Max_Seq
(
  violator_id NUMERIC(29),
  violator_addr_seq INT64,
  city STRING,
  state STRING,
  zip_code STRING,
  plus4 STRING,
  address1 STRING,
  address2 STRING,
  addr_status STRING
)
cluster by violator_id
;
