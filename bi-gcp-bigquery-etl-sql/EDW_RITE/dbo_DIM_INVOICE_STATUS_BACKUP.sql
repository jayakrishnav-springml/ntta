## Translation time: 2024-03-21T20:56:06.764423Z
## Translation job ID: e212c5d3-a7fa-4886-93b1-cb3be341e70a
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/EDW_RITE/Tables/dbo_DIM_INVOICE_STATUS_BACKUP.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_RITE.Dim_Invoice_Status_Backup
(
  zi_stage_id INT64 NOT NULL,
  vbi_status STRING NOT NULL,
  viol_inv_status STRING NOT NULL,
  invoice_status_descr STRING NOT NULL,
  invoice_status_descr_sum_group STRING NOT NULL,
  insert_date DATETIME NOT NULL,
  last_update_date DATETIME NOT NULL
)
cluster by zi_stage_id
;