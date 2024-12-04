CREATE TABLE IF NOT EXISTS EDW_TER.zzFact_Violator_Transaction_Violator_Account_Tag_Stage_22
(
  violator_id INT64 NOT NULL,
  vid_seq INT64 NOT NULL,
  lic_plate_nbr STRING NOT NULL,
  lic_plate_state STRING,
  last_qualified_tran_date DATE NOT NULL,
  hv_designation_start_date DATE NOT NULL,
  hv_designation_end_date DATE NOT NULL,
  license_plate_id INT64 NOT NULL,
  tag_id STRING NOT NULL,
  acct_id INT64 NOT NULL,
  expired_date DATE,
  ttxn_id INT64 NOT NULL,
  posted_date STRING,
  posted_time_id INT64,
  tt_trans_mmyyyy STRING,
  amount NUMERIC(33, 4) NOT NULL,
  lane_id INT64 NOT NULL,
  source_code STRING NOT NULL,
  trans_type_id INT64,
  credited_flag STRING,
  transaction_date STRING,
  transaction_time_id INT64,
  rn INT64
)
cluster by violator_id,vid_seq
;