--Translated manually via BQ Interactive tool

CREATE TABLE IF NOT EXISTS LND_LG_VPS.Vp_Owner_Ca_Companies
(
  ca_company_id INT64 NOT NULL,
  ca_company_name STRING NOT NULL,
  ca_company_descr STRING,
  is_active STRING DEFAULT 'Y' NOT NULL,
  created_by STRING NOT NULL,
  date_created DATE NOT NULL,
  modified_by STRING,
  date_modified DATE,
  ca_abbrev STRING NOT NULL,
  new_enabled STRING DEFAULT 'Y' NOT NULL,
  pay_enabled STRING DEFAULT 'Y' NOT NULL,
  undo_enabled STRING DEFAULT 'Y' NOT NULL,
  min_amt_due NUMERIC(31, 2),
  max_amt_due NUMERIC(31, 2),
  max_new_accts NUMERIC(29) NOT NULL,
  new_acct_priority INT64 NOT NULL,
  display_name STRING,
  ca_phone_number STRING,
  new_acct_percentage FLOAT64,
  child_ca_company_id INT64,
  is_primary STRING,
  last_update_date DATETIME,
  last_update_type STRING
)
cluster by ca_company_id
;
