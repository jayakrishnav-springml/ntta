## Translation time: 2024-03-21T20:56:06.764423Z
## Translation job ID: e212c5d3-a7fa-4886-93b1-cb3be341e70a
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/EDW_RITE/Tables/dbo_ACCOUNT_TAGS.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_RITE.Account_Tags
(
  acct_id NUMERIC(29) NOT NULL,
  acct_tag_seq INT64 NOT NULL,
  tag_id STRING NOT NULL,
  agency_id STRING NOT NULL,
  acct_tag_status STRING NOT NULL,
  assigned_date DATETIME,
  date_modified DATETIME,
  vehicle_id INT64 NOT NULL,
  vehicle_color_id INT64 NOT NULL,
  vehicle_class_code STRING NOT NULL,
  license_plate_id INT64 NOT NULL,
  expir_date DATETIME,
  date_created DATETIME NOT NULL,
  last_update_type STRING,
  last_update_date DATETIME
)
cluster by acct_id , acct_tag_seq
;
