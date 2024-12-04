## Translation time: 2024-03-21T20:56:06.764423Z
## Translation job ID: e212c5d3-a7fa-4886-93b1-cb3be341e70a
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/EDW_RITE/Tables/dbo_TAG_TYPES.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_RITE.Tag_Types
(
  tag_type STRING NOT NULL,
  tag_type_descr STRING,
  tag_type_order INT64,
  default_value_flag STRING NOT NULL,
  active_flag STRING NOT NULL,
  last_update_type STRING,
  last_update_date DATETIME
)
;
