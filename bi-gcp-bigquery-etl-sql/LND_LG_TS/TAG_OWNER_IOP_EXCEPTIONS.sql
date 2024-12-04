-- Translation time: 2024-06-04T08:03:02.538216Z
-- Translation job ID: 2ee163b6-d1ed-4585-9295-ffd9f05ba970
-- Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_LG_TS/Tables/TAG_OWNER_IOP_EXCEPTIONS.sql
-- Translated from: SqlServer
-- Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_LG_TS.Tag_Owner_Iop_Exceptions
(
  iop_exception_id BIGNUMERIC(48, 10) NOT NULL,
  tag_id STRING,
  acct_id BIGNUMERIC(48, 10),
  agency_code STRING,
  txn_type STRING,
  txn_sub_type STRING,
  entry_txn_datetime DATETIME,
  entry_lane_id BIGNUMERIC(48, 10),
  entry_tvl_tag_status STRING,
  source_code STRING,
  txn_id NUMERIC(29),
  earned_class STRING,
  earned_revenue NUMERIC(31, 2),
  disposition STRING,
  reason_code STRING,
  posted_class STRING,
  posted_revenue NUMERIC(31, 2),
  posted_datetime DATETIME,
  repost_attempts BIGNUMERIC(48, 10),
  attribute_1 STRING,
  attribute_2 STRING,
  attribute_3 STRING,
  attribute_4 STRING,
  attribute_5 STRING,
  attribute_6 STRING,
  attribute_7 STRING,
  attribute_8 STRING,
  attribute_9 STRING,
  attribute_10 STRING,
  exception_type STRING,
  processed_date DATETIME,
  processed_by STRING,
  processed_flag STRING,
  exit_txn_datetime DATETIME,
  exit_lane_id BIGNUMERIC(48, 10),
  exit_tvl_tag_status STRING,
  notification_flag STRING,
  review_step INT64,
  last_update_date DATETIME,
  last_update_type STRING
)
;
