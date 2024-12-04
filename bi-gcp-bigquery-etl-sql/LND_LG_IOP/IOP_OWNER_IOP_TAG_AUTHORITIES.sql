-- Translation time: 2024-06-04T08:01:15.437249Z
-- Translation job ID: a14a1a7f-7d63-47c9-8296-0b7483d5c271
-- Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_LG_IOP/Tables/IOP_OWNER_IOP_TAG_AUTHORITIES.sql
-- Translated from: SqlServer
-- Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_LG_IOP.Iop_Owner_Iop_Tag_Authorities
(
  ta_id INT64 NOT NULL,
  tag_identifier STRING NOT NULL,
  name STRING NOT NULL,
  barcode_prefix STRING,
  ta_lc_id INT64 NOT NULL,
  is_active STRING NOT NULL,
  created_by STRING NOT NULL,
  date_created DATETIME NOT NULL,
  modified_by STRING NOT NULL,
  date_modified DATETIME NOT NULL,
  tag_agency_id STRING,
  last_update_type STRING,
  last_update_date DATETIME
)
;
