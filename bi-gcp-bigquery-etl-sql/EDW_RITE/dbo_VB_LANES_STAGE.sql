## Translation time: 2024-03-21T20:56:06.764423Z
## Translation job ID: e212c5d3-a7fa-4886-93b1-cb3be341e70a
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/EDW_RITE/Tables/dbo_VB_LANES_STAGE.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_RITE.Vb_Lanes_Stage
(
  vbl_id NUMERIC(29) NOT NULL,
  lane_id NUMERIC(29) NOT NULL,
  vbl_start DATETIME NOT NULL,
  vbl_end DATETIME,
  last_update_date DATETIME NOT NULL
)
cluster by vbl_id
;
