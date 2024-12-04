-- Translation time: 2024-06-04T07:57:18.317878Z
-- Translation job ID: b2abff43-eccf-406a-aa5d-053048797d89
-- Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_LG_HOST/Tables/TXNOWNER_AU_TXN_ADJ_DETAILS.sql
-- Translated from: SqlServer
-- Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_LG_HOST.TxnOwner_Au_Txn_Adj_Details
(
  atd_id NUMERIC(29),
  opnm_opnm_id NUMERIC(29) NOT NULL,
  pmty_pmty_id NUMERIC(29) NOT NULL,
  vcly_vcly_id NUMERIC(29) NOT NULL,
  lane_lane_id NUMERIC(29) NOT NULL,
  ata_ata_id NUMERIC(29) NOT NULL,
  tart_tart_id NUMERIC(29),
  dummy_tart_id NUMERIC(29),
  date_time DATETIME NOT NULL,
  ear_rev NUMERIC(29) NOT NULL,
  exp_rev NUMERIC(29) NOT NULL,
  sign_flg INT64 NOT NULL,
  latest STRING NOT NULL,
  created_by STRING NOT NULL,
  creation_date DATETIME NOT NULL,
  updated_by STRING NOT NULL,
  updated_date DATETIME NOT NULL,
  rev_axle_ct INT64 NOT NULL,
  att_class NUMERIC(29) NOT NULL,
  fwd_axle_ct NUMERIC(29) NOT NULL,
  exit_loop_cts INT64 NOT NULL,
  att_fare NUMERIC(31, 2) NOT NULL,
  pre_class NUMERIC(29) NOT NULL,
  misclass_ct INT64 NOT NULL,
  last_update_type STRING NOT NULL,
  last_update_date DATETIME NOT NULL
)
;
