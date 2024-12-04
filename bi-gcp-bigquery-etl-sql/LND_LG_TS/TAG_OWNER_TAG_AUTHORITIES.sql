-- Translation time: 2024-06-04T08:03:02.538216Z
-- Translation job ID: 2ee163b6-d1ed-4585-9295-ffd9f05ba970
-- Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_LG_TS/Tables/TAG_OWNER_TAG_AUTHORITIES.sql
-- Translated from: SqlServer
-- Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_LG_TS.Tag_Owner_Tag_Authorities
(
  ta_id INT64 NOT NULL,
  tag_identifier STRING NOT NULL,
  name STRING NOT NULL,
  barcode_prefix STRING,
  ta_lc_id INT64 NOT NULL,
  is_active STRING NOT NULL,
  is_local_tag_agency STRING,
  last_update_type STRING NOT NULL,
  last_update_date DATETIME NOT NULL
)
;
