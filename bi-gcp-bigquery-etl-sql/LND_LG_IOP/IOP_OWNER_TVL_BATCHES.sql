--Translated manually via BQ Interactive tool

CREATE TABLE IF NOT EXISTS LND_LG_IOP.Iop_Owner_Tvl_Batches
(
  tvl_batch_id NUMERIC(29) NOT NULL,
  tvl_agcy_id NUMERIC(29) NOT NULL,
  tvl_src_agcy_id NUMERIC(29) NOT NULL,
  tvl_batch_status STRING NOT NULL,
  batch_mode STRING NOT NULL,
  tvl_file_name STRING,
  tvl_batch_date DATETIME NOT NULL,
  peer_tvl_batch_id NUMERIC(29),
  peer_tvl_batch_date DATETIME,
  tvl_upd_type STRING NOT NULL,
  raw_file_hdr STRING,
  raw_rec_hdr STRING,
  raw_rh_rec_count STRING,
  created_by STRING NOT NULL,
  date_created DATETIME NOT NULL,
  modified_by STRING NOT NULL,
  date_modified DATETIME NOT NULL,
  file_date_time_created DATETIME,
  agcy_id NUMERIC(29),
  last_update_type STRING DEFAULT 'I' NOT NULL,
  last_update_date DATETIME NOT NULL
)
;
