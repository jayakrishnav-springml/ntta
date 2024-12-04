## Translation time: 2024-03-21T20:56:06.764423Z
## Translation job ID: e212c5d3-a7fa-4886-93b1-cb3be341e70a
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/EDW_RITE/Tables/dbo_TOLL_TAGS.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_RITE.Toll_Tags
(
  tt_id INT64,
  agency_id STRING NOT NULL,
  tag_id STRING NOT NULL,
  tag_status STRING NOT NULL,
  last_read_loc STRING,
  last_read_date DATETIME,
  tag_type_code STRING NOT NULL,
  owner_agency STRING NOT NULL,
  pos_id INT64 NOT NULL,
  last_update_type STRING,
  last_update_date DATETIME
)
cluster by tt_id
;
