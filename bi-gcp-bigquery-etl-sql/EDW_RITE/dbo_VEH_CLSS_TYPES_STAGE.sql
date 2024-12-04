## Translation time: 2024-03-21T20:56:06.764423Z
## Translation job ID: e212c5d3-a7fa-4886-93b1-cb3be341e70a
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/EDW_RITE/Tables/dbo_VEH_CLSS_TYPES_STAGE.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_RITE.Veh_Clss_Types_Stage
(
  vcly_desc STRING NOT NULL,
  note STRING,
  axles INT64 NOT NULL,
  created_by STRING NOT NULL,
  creation_date DATETIME NOT NULL,
  updated_by STRING NOT NULL,
  updated_date DATETIME NOT NULL,
  vcly_id NUMERIC(29) NOT NULL,
  vehy_id NUMERIC(29) NOT NULL,
  displayed STRING NOT NULL,
  vcly_order INT64 NOT NULL,
  last_update_date DATETIME,
  last_update_type STRING
)
cluster by vcly_id
;
