## Translation time: 2024-03-04T06:41:57.683170Z
## Translation job ID: 00dc6676-2c12-444a-b02a-71c7788bdc89
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/EDW_TRIPS/Tables/dbo_Dim_TransactionPostingType.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_TRIPS.Dim_TransactionPostingType
(
  transactionpostingtypeid INT64 NOT NULL,
  transactionpostingtype STRING NOT NULL,
  transactionpostingtypedesc STRING NOT NULL,
  transactionpostingtypegroup STRING,
  edw_updateddate TIMESTAMP NOT NULL
)
cluster by transactionpostingtypeid
;