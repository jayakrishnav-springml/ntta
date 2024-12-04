## Translation time: 2024-03-21T20:56:06.764423Z
## Translation job ID: e212c5d3-a7fa-4886-93b1-cb3be341e70a
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/EDW_RITE/Tables/dbo_ACCOUNT_TAG_MAX_ACCT_TAG_SEQ.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_RITE.Account_Tag_Max_Acct_Tag_Seq
(
  acct_id NUMERIC(29) NOT NULL,
  tag_id STRING NOT NULL,
  zip_code STRING,
  zipcode_latitude BIGNUMERIC(50, 12),
  zipcode_longitude BIGNUMERIC(50, 12),
  county STRING,
  county_group STRING,
  acct_type_code STRING NOT NULL,
  acct_status_descr STRING,
  acct_tag_status_descr STRING
)
cluster by acct_id
;
