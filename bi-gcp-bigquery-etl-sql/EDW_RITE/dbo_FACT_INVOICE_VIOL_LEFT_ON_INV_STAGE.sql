## Translation time: 2024-03-21T20:56:06.764423Z
## Translation job ID: e212c5d3-a7fa-4886-93b1-cb3be341e70a
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/EDW_RITE/Tables/dbo_FACT_INVOICE_VIOL_LEFT_ON_INV_STAGE.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_RITE.Fact_Invoice_Viol_Left_On_Inv_Stage
(
  violator_id INT64,
  vbi_invoice_id INT64,
  viol_invoice_id INT64,
  current_invoice_level_flag INT64,
  toll_due_left_on_inv BIGNUMERIC(42, 4),
  txn_cnt_left_on_inv INT64,
  tolls_paid_on_txn BIGNUMERIC(42, 4)
)
;
