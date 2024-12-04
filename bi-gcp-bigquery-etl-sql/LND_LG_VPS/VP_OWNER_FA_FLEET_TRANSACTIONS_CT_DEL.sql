-- Translation time: 2024-06-04T08:04:57.852399Z
-- Translation job ID: d189ef38-1420-4658-96a7-29624b482bd7
-- Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_LG_VPS/Tables/VP_OWNER_FA_FLEET_TRANSACTIONS_CT_DEL.sql
-- Translated from: SqlServer
-- Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_LG_VPS.Vp_Owner_Fa_Fleet_Transactions_Ct_Del
(
  fleet_txn_id NUMERIC(29) NOT NULL,
  fleet_file_id NUMERIC(29) NOT NULL,
  violation_id BIGNUMERIC(48, 10) NOT NULL,
  batch_id NUMERIC(29) NOT NULL,
  lic_plate_nbr STRING NOT NULL,
  viol_date DATETIME NOT NULL,
  contract_id STRING,
  first_name STRING,
  last_name STRING,
  address1 STRING,
  address2 STRING,
  city STRING,
  zip STRING,
  plus4 STRING,
  addr_state STRING,
  phone STRING,
  driver_lic_nbr STRING,
  driver_lic_state STRING,
  txn_send_date DATETIME,
  txn_return_date DATETIME,
  rent_start DATETIME,
  rent_end DATETIME,
  date_created DATETIME NOT NULL,
  date_modified DATETIME NOT NULL,
  modified_by STRING NOT NULL,
  created_by STRING NOT NULL,
  lic_plate_state STRING NOT NULL,
  plate_type_code STRING,
  batch_record_number INT64,
  rca_file_sequence NUMERIC(29),
  rca_record_number INT64,
  toll_due NUMERIC(31, 2),
  lane_name STRING,
  image_filename STRING,
  payment_xref_id INT64,
  insert_datetime DATETIME NOT NULL
)
;
