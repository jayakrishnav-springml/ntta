## Translation time: 2024-03-21T20:56:06.764423Z
## Translation job ID: e212c5d3-a7fa-4886-93b1-cb3be341e70a
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/EDW_RITE/Tables/dbo_FACT_INVOICE_DETAIL_CURRENT_INVOICE_LEVEL_FLAG_DUPS_STAGE1.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_RITE.Fact_Invoice_Detail_Current_Invoice_Level_Flag_Dups_Stage1
(
  violator_id INT64 NOT NULL,
  partition_date DATE NOT NULL,
  violation_id INT64 NOT NULL
)
;
