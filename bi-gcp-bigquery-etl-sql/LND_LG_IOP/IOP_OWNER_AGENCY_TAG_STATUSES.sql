--Translated manually via BQ Interactive tool

CREATE TABLE IF NOT EXISTS LND_LG_IOP.Iop_Owner_Agency_Tag_Statuses
(
  agcy_id NUMERIC(29) NOT NULL,
  agency_tag_status STRING NOT NULL,
  iop_tag_status STRING NOT NULL,
  order_by INT64,
  is_active STRING NOT NULL,
  created_by STRING NOT NULL,
  date_created DATETIME NOT NULL,
  modified_by STRING NOT NULL,
  date_modified DATETIME NOT NULL,
  hub_tvl_tag_status STRING,
  last_update_type STRING DEFAULT 'I' NOT NULL,
  last_update_date DATETIME NOT NULL
)
;
