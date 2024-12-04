## Translation time: 2024-03-21T20:56:06.764423Z
## Translation job ID: e212c5d3-a7fa-4886-93b1-cb3be341e70a
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/EDW_RITE/Tables/dbo_ACCOUNTS.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_RITE.Accounts
(
  acct_id NUMERIC(29) NOT NULL,
  first_name STRING,
  middle_initial STRING,
  last_name STRING,
  address1 STRING,
  address2 STRING,
  city STRING,
  state STRING,
  zip_code STRING,
  plus4 STRING,
  home_pho_nbr STRING,
  work_pho_nbr STRING,
  work_pho_ext STRING,
  driver_lic_nbr STRING,
  driver_lic_state STRING,
  company_name STRING,
  company_tax_id STRING,
  email_address STRING,
  bad_address_flag STRING NOT NULL,
  rebill_failed_flag STRING NOT NULL,
  rebill_amt NUMERIC(31, 2),
  rebill_date DATETIME,
  dep_amt NUMERIC(31, 2),
  balance_amt NUMERIC(31, 2),
  low_bal_level NUMERIC(31, 2),
  bal_last_updated DATETIME,
  acct_status_code STRING NOT NULL,
  acct_type_code STRING NOT NULL,
  pmt_type_code STRING NOT NULL,
  address_modified DATETIME,
  date_created DATETIME NOT NULL,
  created_by STRING NOT NULL,
  date_approved DATETIME,
  approved_by STRING,
  date_modified DATETIME,
  modified_by STRING,
  selected_for_rebill STRING,
  ms_id NUMERIC(29),
  vea_flag STRING NOT NULL,
  vea_date DATETIME,
  vea_expire_date DATETIME,
  company_code STRING,
  adjust_rebill_amt STRING NOT NULL,
  close_out_status STRING,
  close_out_date DATETIME,
  close_out_type STRING,
  last_update_date DATETIME,
  last_update_type STRING
)
;
