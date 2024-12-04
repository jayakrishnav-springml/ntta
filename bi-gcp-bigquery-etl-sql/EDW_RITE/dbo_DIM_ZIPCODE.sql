## Translation time: 2024-03-21T20:56:06.764423Z
## Translation job ID: e212c5d3-a7fa-4886-93b1-cb3be341e70a
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/EDW_RITE/Tables/dbo_DIM_ZIPCODE.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_RITE.Dim_Zipcode
(
  zipcode STRING NOT NULL,
  zipcode_latitude BIGNUMERIC(50, 12) NOT NULL,
  zipcode_longitude BIGNUMERIC(50, 12) NOT NULL,
  county STRING,
  county_group STRING NOT NULL,
  insert_date DATETIME NOT NULL,
  last_update_date DATETIME NOT NULL
)
;
