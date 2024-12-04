--Translated manually via BQ Interactive tool

CREATE TABLE IF NOT EXISTS LND_LG_IOP.Iop_Owner_Agency_Vehicle_Classes_Truncate
(
  agcy_id NUMERIC(29) NOT NULL,
  agcy_vehicle_class_code STRING NOT NULL,
  agcy_vehicle_class_desc STRING,
  vehicle_class_code INT64 NOT NULL,
  created_by STRING NOT NULL,
  date_created DATETIME NOT NULL,
  modified_by STRING NOT NULL,
  date_modified DATETIME NOT NULL,
  last_update_type STRING DEFAULT 'I' NOT NULL,
  last_update_date DATETIME NOT NULL
)
;
