## Translation time: 2024-03-21T20:56:06.764423Z
## Translation job ID: e212c5d3-a7fa-4886-93b1-cb3be341e70a
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/EDW_RITE/Tables/dbo_FACT_TOLL_TAG_PENETRATION.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_RITE.Fact_Toll_Tag_Penetration
(
  day_id INT64 NOT NULL,
  zip_code STRING,
  lane_id INT64 NOT NULL,
  toll_txn_cnt INT64,
  video_txn_cnt INT64,
  tt_percnt NUMERIC(33, 4)
)
;
