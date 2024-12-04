--Translated manually via BQ Interactive tool

CREATE TABLE IF NOT EXISTS LND_LG_IOP.Iop_Owner_Iop_Tags
(
  tag_id STRING NOT NULL,
  tag_identifier STRING NOT NULL,
  hia_agcy_id NUMERIC(29) NOT NULL,
  not_iop STRING,
  block_tag_rsn_code STRING,
  tag_updated_by STRING,
  created_by STRING NOT NULL,
  date_created DATETIME NOT NULL,
  modified_by STRING NOT NULL,
  date_modified DATETIME NOT NULL,
  last_update_type STRING DEFAULT 'I' NOT NULL,
  last_update_date DATETIME NOT NULL
)
;
