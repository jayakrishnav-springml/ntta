## Translation time: 2024-03-21T20:56:06.764423Z
## Translation job ID: e212c5d3-a7fa-4886-93b1-cb3be341e70a
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/EDW_RITE/Tables/dbo_DIM_INVOICE_ANALYSIS_CATEGORY.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_RITE.Dim_Invoice_Analysis_Category
(
  invoice_analysis_category_id INT64 NOT NULL,
  invoice_analysis_category STRING NOT NULL
)
cluster by invoice_analysis_category_id
;
