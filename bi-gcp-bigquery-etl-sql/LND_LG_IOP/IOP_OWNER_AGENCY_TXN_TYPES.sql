--Translated manually via BQ Interactive tool

CREATE TABLE IF NOT EXISTS LND_LG_IOP.Iop_Owner_Agency_Txn_Types
(
  agcy_id NUMERIC(29) NOT NULL,
  agency_txn_type STRING NOT NULL,
  is_active STRING NOT NULL,
  iop_txn_type STRING NOT NULL,
  order_by INT64,
  created_by STRING NOT NULL,
  date_created DATETIME NOT NULL,
  modified_by STRING NOT NULL,
  date_modified DATETIME NOT NULL,
  max_fare_amt NUMERIC(31, 2),
  min_fare_amt NUMERIC(31, 2),
  max_txn_age STRING,
  min_txn_age STRING,
  comments STRING,
  last_update_type STRING DEFAULT 'I' NOT NULL,
  last_update_date DATETIME NOT NULL
)
;
