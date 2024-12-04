-- Translation time: 2024-06-04T07:57:18.317878Z
-- Translation job ID: b2abff43-eccf-406a-aa5d-053048797d89
-- Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_LG_HOST/Tables/TXNOWNER_HA_ADJ_TFC_SUM_DETAILS.sql
-- Translated from: SqlServer
-- Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_LG_HOST.TxnOwner_Ha_Adj_Tfc_Sum_Details
(
  summary_type STRING NOT NULL,
  end_time DATE NOT NULL,
  summ_time DATE NOT NULL,
  bus_day DATE NOT NULL,
  veh_tot_cnt NUMERIC(29) NOT NULL,
  veh_avi_cnt NUMERIC(29) NOT NULL,
  veh_avi_nr_cnt NUMERIC(29) NOT NULL,
  veh_avi_inv_cnt NUMERIC(29) NOT NULL,
  veh_acm_cnt NUMERIC(29) NOT NULL,
  veh_cash_att_cnt NUMERIC(29) NOT NULL,
  veh_no_fund_cnt NUMERIC(29) NOT NULL,
  veh_at_nr_cnt NUMERIC(29) NOT NULL,
  veh_part_vio_pmt_cnt NUMERIC(29) NOT NULL,
  veh_avi_vio_cnt NUMERIC(29) NOT NULL,
  veh_vio_cnt NUMERIC(29) NOT NULL,
  rev_tot_earned NUMERIC(29) NOT NULL,
  rev_tot_exp NUMERIC(29) NOT NULL,
  rev_tot_act NUMERIC(29) NOT NULL,
  rev_avi NUMERIC(29) NOT NULL,
  rev_avi_nr NUMERIC(29) NOT NULL,
  rev_avi_inv NUMERIC(29) NOT NULL,
  rev_acm NUMERIC(29) NOT NULL,
  rev_cash_att NUMERIC(29) NOT NULL,
  rev_no_fund NUMERIC(29) NOT NULL,
  rev_avi_vio NUMERIC(29) NOT NULL,
  rev_cash_vio NUMERIC(29) NOT NULL,
  rev_part_vio_pmt NUMERIC(29) NOT NULL,
  misclass_ct NUMERIC(29) NOT NULL,
  vplt_id NUMERIC(29) NOT NULL,
  att_empl_id NUMERIC(29) NOT NULL,
  opnm_id NUMERIC(29) NOT NULL,
  avg_hshks NUMERIC(29) NOT NULL,
  exit_loop NUMERIC(29) NOT NULL,
  mid_loop NUMERIC(29) NOT NULL,
  ent_loop NUMERIC(29) NOT NULL,
  fwd_axles NUMERIC(29) NOT NULL,
  rev_axles NUMERIC(29) NOT NULL,
  hatsd_id NUMERIC(29),
  lane_lane_id NUMERIC(29) NOT NULL,
  vcly_id NUMERIC(29) NOT NULL,
  pmty_id NUMERIC(29),
  last_update_type STRING NOT NULL,
  last_update_date DATETIME NOT NULL
)
cluster by hatsd_id
;
