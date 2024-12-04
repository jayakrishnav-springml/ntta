-- Translation time: 2024-07-11T07:10:16.441155Z
-- Translation job ID: 01f97d19-b914-463a-8c9e-73c23536d6e1
-- Source: gs://ntta-gcp-poc-source-code-scripts/transpiled_ddl_tmp/ITEM_90_NEW_APS/Stage.UnassignedInvoice.dsql
-- Translated from: SqlServer
-- Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_TRIPS_STAGE.UnassignedInvoice
(
  invoicenumber_unass STRING,
  citationid_unassgned INT64,
  unassignedtxncnt INT64,
  invoicenumber STRING,
  citationid_all INT64,
  tolls BIGNUMERIC(40, 2),
  unassignedflag INT64 NOT NULL
)
;
