-- Translation time: 2024-06-04T07:57:18.317878Z
-- Translation job ID: b2abff43-eccf-406a-aa5d-053048797d89
-- Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_LG_HOST/Tables/TSA_OWNER_TAG_AUTHORITIES.sql
-- Translated from: SqlServer
-- Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_LG_HOST.Tsa_Owner_Tag_Authorities
(
  ta_id INT64 NOT NULL,
  tag_identifier STRING NOT NULL,
  name STRING NOT NULL,
  barcode_prefix STRING,
  ta_lc_id INT64 NOT NULL,
  is_active STRING NOT NULL,
  last_update_type STRING NOT NULL,
  last_update_date DATETIME NOT NULL
)
cluster by ta_id
;
