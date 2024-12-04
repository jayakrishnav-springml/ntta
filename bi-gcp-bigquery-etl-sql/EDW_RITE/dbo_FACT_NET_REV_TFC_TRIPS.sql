## Translation time: 2024-03-21T20:56:06.764423Z
## Translation job ID: e212c5d3-a7fa-4886-93b1-cb3be341e70a
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/EDW_RITE/Tables/dbo_FACT_NET_REV_TFC_TRIPS.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_RITE.Fact_Net_Rev_Tfc_Trips
(
  tart_id NUMERIC(29),
  transaction_file_detail_id NUMERIC(29)
)
CLUSTER BY transaction_file_detail_id;
