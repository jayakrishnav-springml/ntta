--Translated manually via BQ Interactive tool

CREATE TABLE IF NOT EXISTS LND_LG_IOP.Iop_Owner_Txn_Batchesc28e13adfca9430a8a1934815ee4484c
(
  txn_batch_id NUMERIC(29) NOT NULL,
  txn_batch_agcy_id NUMERIC(29) NOT NULL,
  hia_agency_id NUMERIC(29) NOT NULL,
  txn_batch_date DATETIME NOT NULL,
  file_name STRING,
  batch_mode STRING NOT NULL,
  txn_batch_status STRING NOT NULL,
  txn_batch_type STRING NOT NULL,
  peer_txn_batch_id NUMERIC(29),
  peer_txn_batch_date DATETIME,
  raw_file_hdr STRING,
  raw_rec_hdr STRING,
  raw_fh_file_chksum STRING,
  raw_fh_file_size STRING,
  raw_fh_file_name STRING,
  raw_rh_rec_code STRING,
  raw_rh_orig_auth STRING,
  raw_rh_date_time_created STRING,
  raw_rh_rec_cnt STRING,
  raw_rh_batch_id STRING,
  raw_rh_file_name STRING,
  created_by STRING NOT NULL,
  date_created DATETIME NOT NULL,
  modified_by STRING NOT NULL,
  date_modified DATETIME NOT NULL,
  last_update_type STRING DEFAULT 'I' NOT NULL,
  last_update_date DATETIME NOT NULL
)
;
