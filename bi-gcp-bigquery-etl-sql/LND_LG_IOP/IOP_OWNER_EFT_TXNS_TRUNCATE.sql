--Translated manually via BQ Interactive tool

CREATE TABLE IF NOT EXISTS LND_LG_IOP.Iop_Owner_Eft_Txns_Truncate
(
  eft_txn_id NUMERIC(29) NOT NULL,
  agcy_eft_seq NUMERIC(29) NOT NULL,
  agcy_id NUMERIC(29) NOT NULL,
  eft_txn_date DATETIME NOT NULL,
  eft_posted_date DATETIME NOT NULL,
  eft_fee NUMERIC(31, 2),
  eft_txn_amount NUMERIC(31, 2) NOT NULL,
  created_by STRING NOT NULL,
  date_created DATETIME NOT NULL,
  modified_by STRING NOT NULL,
  date_modified DATETIME NOT NULL,
  eft_cr_amount NUMERIC(31, 2),
  eft_dr_amount NUMERIC(31, 2),
  last_update_type STRING DEFAULT 'I' NOT NULL,
  last_update_date DATETIME NOT NULL
)
;
