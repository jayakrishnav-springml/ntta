## Translation time: 2024-03-21T20:56:06.764423Z
## Translation job ID: e212c5d3-a7fa-4886-93b1-cb3be341e70a
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/EDW_RITE/Tables/dbo_LANE_ID_VIOL_DATE_LANE_VIOL_ID.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_RITE.Lane_Id_Viol_Date_Lane_Viol_Id
(
  lane_viol_id NUMERIC(29) NOT NULL,
  lane_id NUMERIC(29) NOT NULL,
  sequence_nbr NUMERIC(29),
  viol_date DATETIME NOT NULL
)
;
