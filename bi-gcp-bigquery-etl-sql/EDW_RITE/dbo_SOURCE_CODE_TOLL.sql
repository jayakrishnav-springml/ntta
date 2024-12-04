## Translation time: 2024-03-21T20:56:06.764423Z
## Translation job ID: e212c5d3-a7fa-4886-93b1-cb3be341e70a
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/EDW_RITE/Tables/dbo_SOURCE_CODE_TOLL.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_RITE.Source_Code_Toll
(
  source_code STRING NOT NULL,
  sc_descr STRING NOT NULL,
  source_code_group STRING NOT NULL,
  last_update_date DATETIME NOT NULL
)
;
