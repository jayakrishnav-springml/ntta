--Translated manually via BQ Interactive tool

CREATE TABLE IF NOT EXISTS LND_LG_IOP.Iop_Owner_Tvl_Batch_Acks
(
  tvl_ba_id NUMERIC(29) NOT NULL,
  tvl_batch_id NUMERIC(29) NOT NULL,
  batch_mode STRING NOT NULL,
  tvl_batch_ack_status STRING NOT NULL,
  file_ack_name STRING NOT NULL,
  file_ack_status STRING NOT NULL,
  file_ack_date DATETIME NOT NULL,
  actual_activation_date DATETIME,
  bd_id NUMERIC(29),
  raw_ack_file_hdr STRING,
  raw_ack_rec_hdr STRING,
  raw_arh_rec_cnt STRING,
  raw_arh_valid_rec_cnt STRING,
  raw_arh_invalid_rec_cnt STRING,
  created_by STRING NOT NULL,
  date_created DATETIME NOT NULL,
  modified_by STRING NOT NULL,
  date_modified DATETIME NOT NULL,
  last_update_type STRING DEFAULT 'I' NOT NULL,
  last_update_date DATETIME NOT NULL
)
;
