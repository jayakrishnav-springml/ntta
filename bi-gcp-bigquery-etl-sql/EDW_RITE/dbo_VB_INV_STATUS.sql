## Translation time: 2024-03-21T20:56:06.764423Z
## Translation job ID: e212c5d3-a7fa-4886-93b1-cb3be341e70a
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/EDW_RITE/Tables/dbo_VB_INV_STATUS.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_RITE.Vb_Inv_Status
(
  status STRING NOT NULL,
  description STRING,
  status_group STRING NOT NULL,
  status_sum_group STRING NOT NULL,
  is_closed STRING NOT NULL,
  insert_date DATETIME,
  last_update_date DATETIME
)
;
