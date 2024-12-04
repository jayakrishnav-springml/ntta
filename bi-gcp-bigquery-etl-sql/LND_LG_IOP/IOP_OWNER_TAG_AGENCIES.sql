-- Translation time: 2024-06-04T08:01:15.437249Z
-- Translation job ID: a14a1a7f-7d63-47c9-8296-0b7483d5c271
-- Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_LG_IOP/Tables/IOP_OWNER_TAG_AGENCIES.sql
-- Translated from: SqlServer
-- Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_LG_IOP.Iop_Owner_Tag_Agencies
(
  tag_agency_id STRING NOT NULL,
  tag_agency_desc STRING,
  tag_encoded_tdm STRING,
  tag_encoded_6c STRING,
  tag_encoded_sego STRING,
  tag_encoded_ata STRING,
  order_by INT64,
  is_active STRING NOT NULL,
  created_by STRING NOT NULL,
  date_created DATETIME NOT NULL,
  modified_by STRING NOT NULL,
  date_modified DATETIME NOT NULL,
  last_update_date DATETIME,
  last_update_type STRING
)
;
