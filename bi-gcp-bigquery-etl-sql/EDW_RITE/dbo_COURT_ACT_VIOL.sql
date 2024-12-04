## Translation time: 2024-03-21T20:56:06.764423Z
## Translation job ID: e212c5d3-a7fa-4886-93b1-cb3be341e70a
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/EDW_RITE/Tables/dbo_COURT_ACT_VIOL.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_RITE.Court_Act_Viol
(
  court_action_id INT64 NOT NULL,
  viol_invoice_id NUMERIC(29) NOT NULL,
  violation_id FLOAT64 NOT NULL,
  fine_amount NUMERIC(33, 4),
  last_update_type STRING NOT NULL,
  last_update_date DATETIME NOT NULL
)
;