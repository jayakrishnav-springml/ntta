## Translation time: 2024-03-21T20:56:06.764423Z
## Translation job ID: e212c5d3-a7fa-4886-93b1-cb3be341e70a
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/EDW_RITE/Tables/dbo_AU_TXN_ADJ_DETAILS.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_RITE.Au_Txn_Adj_Details
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
