-- Translation time: 2024-06-04T08:04:57.852399Z
-- Translation job ID: d189ef38-1420-4658-96a7-29624b482bd7
-- Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_LG_VPS/Tables/VP_OWNER_PERF_IRS_REJ_REP_SUMM_CT_INS.sql
-- Translated from: SqlServer
-- Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_LG_VPS.Vp_Owner_Perf_Irs_Rej_Rep_Summ_Ct_Ins
(
  review_date DATETIME NOT NULL,
  count BIGNUMERIC(48, 10),
  lane_id NUMERIC(29),
  viol_reject_type STRING,
  ocr_nbr_confid INT64,
  review_status STRING,
  date_created DATETIME NOT NULL,
  created_by STRING NOT NULL,
  date_modified DATETIME NOT NULL,
  modified_by STRING NOT NULL,
  pirj_id BIGNUMERIC(48, 10) NOT NULL,
  summary_type STRING NOT NULL,
  start_time DATETIME NOT NULL,
  end_time DATETIME NOT NULL,
  insert_datetime DATETIME NOT NULL
)
;
