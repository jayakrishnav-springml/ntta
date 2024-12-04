## Translation time: 2024-03-21T20:56:06.764423Z
## Translation job ID: e212c5d3-a7fa-4886-93b1-cb3be341e70a
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/EDW_RITE/Tables/dbo_ALERT_BY_TRAN_CNT_DIM_LANE_OLD.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_RITE.Alert_By_Tran_Cnt_Dim_Lane_Old
(
  lane_id INT64 NOT NULL,
  lane_abbrev STRING NOT NULL,
  plaza_id INT64 NOT NULL,
  plaza_abbrev STRING NOT NULL,
  facility_id NUMERIC(29) NOT NULL,
  facility_abbrev STRING NOT NULL,
  is_ative INT64,
  is_manual INT64
)
cluster by lane_id
;
