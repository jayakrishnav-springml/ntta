--Translated manually via BQ Interactive tool

CREATE TABLE IF NOT EXISTS LND_LG_IOP.Iop_Owner_Iop_Home_Agencies
(
  iha_agcy_id NUMERIC(29) NOT NULL,
  agcy_id NUMERIC(29) NOT NULL,
  created_by STRING NOT NULL,
  date_created DATETIME NOT NULL,
  modified_by STRING NOT NULL,
  date_modified DATETIME NOT NULL,
  last_update_type STRING DEFAULT 'I' NOT NULL,
  last_update_date DATETIME NOT NULL
)
;
