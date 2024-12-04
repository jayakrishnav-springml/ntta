## Translation time: 2024-03-21T20:56:06.764423Z
## Translation job ID: e212c5d3-a7fa-4886-93b1-cb3be341e70a
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/EDW_RITE/Tables/dbo_TAG_ID_TAG_TYPES_XREF.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_RITE.Tag_Id_Tag_Types_Xref
(
  tag_type STRING NOT NULL,
  tag_id_begin INT64,
  tag_id_end INT64,
  tag_model STRING,
  qty INT64
)
cluster by tag_id_begin,tag_id_end
;
