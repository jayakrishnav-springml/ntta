## Translation time: 2024-03-21T20:56:06.764423Z
## Translation job ID: e212c5d3-a7fa-4886-93b1-cb3be341e70a
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/EDW_RITE/Tables/dbo_HOST_AVI_TAG_STATUSES.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_RITE.Host_Avi_Tag_Statuses
(
  avi_tag_status NUMERIC(29) NOT NULL,
  avi_tag_status_descr STRING,
  insert_date DATETIME NOT NULL
)
CLUSTER BY avi_tag_status;
