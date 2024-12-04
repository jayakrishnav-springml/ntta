CREATE TABLE IF NOT EXISTS  EDW_TER.Fact_Violator_Transaction_Violator_Account_Tag_Stage
(
  violatorid INT64 NOT NULL,
  vidseq INT64 NOT NULL,
  hvflag INT64 NOT NULL,
  licplatenbr STRING NOT NULL,
  lic_plate_state STRING,
  last_qualified_tran_date DATE NOT NULL,
  hv_designation_start_date DATE NOT NULL,
  hv_designation_end_date DATE NOT NULL,
  license_plate_id INT64 NOT NULL,
  tag_id STRING,
  acct_id NUMERIC(29),
  assigned_date DATETIME,
  expired_date DATETIME,
  date_created DATETIME
)
cluster by acct_id,violatorid
;