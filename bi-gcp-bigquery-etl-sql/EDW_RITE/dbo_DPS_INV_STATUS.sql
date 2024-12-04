## Translation time: 2024-03-21T20:56:06.764423Z
## Translation job ID: e212c5d3-a7fa-4886-93b1-cb3be341e70a
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/EDW_RITE/Tables/dbo_DPS_INV_STATUS.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_RITE.Dps_Inv_Status
(
  dps_inv_status STRING NOT NULL,
  dps_inv_status_descr STRING,
  dps_inv_status_group STRING,
  insert_date DATETIME NOT NULL,
  last_update_date DATETIME NOT NULL
)
;
