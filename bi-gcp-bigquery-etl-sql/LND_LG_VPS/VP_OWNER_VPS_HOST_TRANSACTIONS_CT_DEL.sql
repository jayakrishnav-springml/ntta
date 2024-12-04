-- Translation time: 2024-06-04T08:04:57.852399Z
-- Translation job ID: d189ef38-1420-4658-96a7-29624b482bd7
-- Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_LG_VPS/Tables/VP_OWNER_VPS_HOST_TRANSACTIONS_CT_DEL.sql
-- Translated from: SqlServer
-- Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_LG_VPS.Vp_Owner_Vps_Host_Transactions_Ct_Del
(
  transaction_id NUMERIC(29) NOT NULL,
  lic_plate_nbr STRING NOT NULL,
  lic_plate_state STRING NOT NULL,
  lane_id NUMERIC(29) NOT NULL,
  plaz_id NUMERIC(29),
  facs_id NUMERIC(29),
  transaction_date DATETIME NOT NULL,
  viol_date DATETIME NOT NULL,
  viol_type STRING NOT NULL,
  violation_id BIGNUMERIC(48, 10),
  lane_viol_id NUMERIC(29),
  time_nbr NUMERIC(29),
  earned_class NUMERIC(29) NOT NULL,
  earned_revenue NUMERIC(31, 2) NOT NULL,
  migration_status STRING NOT NULL,
  source_code STRING NOT NULL,
  agency_code STRING,
  tag_id STRING,
  disposition STRING,
  reason_code STRING,
  posted_class NUMERIC(29),
  posted_revenue NUMERIC(31, 2),
  posted_date DATETIME,
  tag_status_at_txn_date STRING,
  tag_status_at_posted_date STRING,
  notification_date DATETIME,
  gl_status STRING NOT NULL,
  created_by STRING NOT NULL,
  date_created DATETIME NOT NULL,
  date_modified DATETIME,
  modified_by STRING,
  viol_serial_nbr NUMERIC(29),
  process_flag STRING,
  pre_audit_result STRING NOT NULL,
  vtoll_send_date DATETIME,
  insert_datetime DATETIME NOT NULL
)
;
