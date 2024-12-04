CREATE TABLE IF NOT EXISTS EDW_TER.Fact_Ter_Ttxn_Accounts
(
  acct_id NUMERIC(29),
  tag_id STRING,
  hvdate DATE,
  termdate DATE NOT NULL,
  violatorid INT64,
  vidseq INT64,
  license_plate_id INT64 NOT NULL,
  assigned_date DATE,
  expired_date DATE NOT NULL,
  lic_state STRING,
  lic_plate STRING
)
;