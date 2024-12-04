## Translation time: 2024-03-21T20:56:06.764423Z
## Translation job ID: e212c5d3-a7fa-4886-93b1-cb3be341e70a
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/EDW_RITE/Tables/dbo_VIOL_INV_STATUS_STAGE.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_RITE.Viol_Inv_Status_Stage
(
  viol_inv_status STRING NOT NULL,
  viol_inv_status_descr STRING NOT NULL,
  viol_inv_status_order INT64,
  is_closed STRING NOT NULL,
  supervisor_only STRING NOT NULL,
  invoice_only STRING NOT NULL,
  is_active STRING NOT NULL,
  archive STRING NOT NULL,
  is_agable STRING,
  last_update_type STRING NOT NULL,
  last_update_date DATETIME NOT NULL
)
;
