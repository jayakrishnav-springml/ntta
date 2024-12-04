## Translation time: 2024-03-21T20:56:06.764423Z
## Translation job ID: e212c5d3-a7fa-4886-93b1-cb3be341e70a
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/EDW_RITE/Tables/dbo_DIM_PAYMENT_TYPE_HOST_STAGE.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_RITE.Dim_Payment_Type_Host_Stage
(
  pmty_id NUMERIC(29) NOT NULL,
  pmty_desc STRING NOT NULL,
  note STRING,
  last_update_type STRING,
  last_update_date DATETIME
)
cluster by pmty_id
;
