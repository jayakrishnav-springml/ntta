--Translated manually via BQ Interactive tool

CREATE TABLE IF NOT EXISTS LND_LG_IOP.Iop_Owner_Txn_Batch_Details_Truncate
(
  txn_batch_det_id NUMERIC(29) NOT NULL,
  txn_batch_id NUMERIC(29) NOT NULL,
  iop_txn_id NUMERIC(29),
  raw_data_record STRING,
  raw_dr_rec_code STRING,
  raw_dr_ref_id STRING,
  raw_dr_exit_txn_date_time STRING,
  raw_dr_exit_loc STRING,
  raw_dr_entry_txn_date_time STRING,
  raw_dr_entry_loc STRING,
  raw_dr_tag_id STRING,
  raw_dr_exit_tag_status STRING,
  raw_dr_entry_tag_status STRING,
  raw_dr_lic_plate_state STRING,
  raw_dr_lic_plate_nbr STRING,
  raw_dr_veh_class STRING,
  raw_dr_toll_amt STRING,
  raw_dr_recon_ref_id STRING,
  raw_dr_posted_date_time STRING,
  raw_dr_posted_disp STRING,
  raw_dr_amt_paid STRING,
  raw_dr_sur_chg_amt STRING,
  raw_dr_sur_fee_type STRING,
  created_by STRING NOT NULL,
  date_created DATETIME NOT NULL,
  modified_by STRING NOT NULL,
  date_modified DATETIME NOT NULL,
  failed STRING,
  failed_disposition STRING,
  failed_reason STRING,
  failed_disp_status STRING,
  failed_date DATETIME,
  failed_txn_batch_det_id NUMERIC(29),
  raw_dr_is_guaranteed STRING,
  raw_dr_iop_disposition STRING,
  raw_dr_entry_tvl_batch_id STRING,
  raw_dr_exit_tvl_batch_id STRING,
  raw_dr_entry_rev_type STRING,
  raw_dr_exit_rev_type STRING,
  raw_dr_proc_fee_flat STRING,
  raw_dr_proc_fee_flat_type STRING,
  raw_dr_proc_fee_pct STRING,
  raw_dr_proc_fee_pct_type STRING,
  raw_dr_attribute_1 STRING,
  raw_dr_attribute_2 STRING,
  raw_dr_attribute_3 STRING,
  raw_dr_attribute_4 STRING,
  raw_dr_attribute_5 STRING,
  raw_dr_attribute_6 STRING,
  raw_dr_attribute_7 STRING,
  raw_dr_attribute_8 STRING,
  raw_dr_attribute_9 STRING,
  raw_dr_attribute_10 STRING,
  raw_dr_repost_count INT64,
  last_update_type STRING DEFAULT 'I' NOT NULL,
  last_update_date DATETIME NOT NULL
)
;
