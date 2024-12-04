## Translation time: 2024-03-21T20:56:06.764423Z
## Translation job ID: e212c5d3-a7fa-4886-93b1-cb3be341e70a
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/EDW_RITE/Tables/dbo_DIM_STATE.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_RITE.Dim_State
(
  state_code STRING NOT NULL,
  state_name STRING NOT NULL,
  state_latitude BIGNUMERIC(50, 12) NOT NULL,
  state_longitude BIGNUMERIC(50, 12) NOT NULL,
  out_of_state_ind INT64 NOT NULL
)
;
