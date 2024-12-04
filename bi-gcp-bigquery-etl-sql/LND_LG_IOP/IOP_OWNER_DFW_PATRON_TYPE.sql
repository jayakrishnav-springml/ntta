--Translated manually via BQ Interactive tool

CREATE TABLE IF NOT EXISTS LND_LG_IOP.Iop_Owner_Dfw_Patron_Type
(
  ptrny_id INT64 NOT NULL,
  description STRING,
  date_created DATETIME,
  date_modified DATETIME,
  modified_by STRING,
  created_by STRING,
  group_id INT64 NOT NULL,
  abbrev STRING,
  class STRING NOT NULL,
  name STRING NOT NULL,
  list_order INT64,
  is_active STRING NOT NULL,
  transaction_aging_window INT64 NOT NULL,
  segment_aging_window INT64 NOT NULL,
  last_update_type STRING DEFAULT 'I' NOT NULL,
  last_update_date DATETIME NOT NULL
)
;
