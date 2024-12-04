-- Translation time: 2024-06-04T08:04:57.852399Z
-- Translation job ID: d189ef38-1420-4658-96a7-29624b482bd7
-- Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_LG_VPS/Tables/VP_OWNER_PERF_IRSP_REV_REP_SUMM.sql
-- Translated from: SqlServer
-- Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_LG_VPS.Vp_Owner_Perf_Irsp_Rev_Rep_Summ
(
  pirv_id BIGNUMERIC(48, 10) NOT NULL,
  review_date DATETIME NOT NULL,
  review_user_id INT64,
  count_not_n BIGNUMERIC(48, 10),
  count_not_n_o BIGNUMERIC(48, 10),
  date_created DATETIME NOT NULL,
  date_modified DATETIME NOT NULL,
  modified_by STRING NOT NULL,
  created_by STRING NOT NULL,
  summary_type STRING NOT NULL,
  start_time DATETIME NOT NULL,
  end_time DATETIME NOT NULL,
  last_update_date DATETIME,
  last_update_type STRING
)
;
