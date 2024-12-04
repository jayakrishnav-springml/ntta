--Translated manually via BQ Interactive tool

CREATE TABLE IF NOT EXISTS LND_LG_IOP.Iop_Owner_Tvl_Tag_Statuses
(
  tvl_tag_status STRING NOT NULL,
  tvl_tag_status_desc STRING NOT NULL,
  tagstore_tvl_tag_status_id STRING,
  lc_tvl_tag_status_id STRING,
  lc_tag_status_desc STRING,
  order_by INT64,
  is_active STRING NOT NULL,
  gtd_tvl_tag_status STRING,
  created_by STRING NOT NULL,
  date_created DATETIME NOT NULL,
  modified_by STRING NOT NULL,
  date_modified DATETIME NOT NULL,
  last_update_type STRING DEFAULT 'I' NOT NULL,
  last_update_date DATETIME NOT NULL
)
;
