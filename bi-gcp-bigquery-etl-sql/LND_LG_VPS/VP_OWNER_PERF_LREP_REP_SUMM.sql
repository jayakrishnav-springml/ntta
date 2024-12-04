-- Translation time: 2024-06-04T08:04:57.852399Z
-- Translation job ID: d189ef38-1420-4658-96a7-29624b482bd7
-- Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_LG_VPS/Tables/VP_OWNER_PERF_LREP_REP_SUMM.sql
-- Translated from: SqlServer
-- Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_LG_VPS.Vp_Owner_Perf_Lrep_Rep_Summ
(
  plrp_id BIGNUMERIC(48, 10) NOT NULL,
  summary_type STRING NOT NULL,
  start_time DATETIME NOT NULL,
  end_time DATETIME NOT NULL,
  entry_count BIGNUMERIC(48, 10),
  cr_date_fvio DATETIME NOT NULL,
  cr_by_fvio STRING NOT NULL,
  date_created DATETIME NOT NULL,
  date_modified DATETIME NOT NULL,
  modified_by STRING NOT NULL,
  created_by STRING NOT NULL,
  cr_emp_nbr BIGNUMERIC(48, 10),
  last_update_date DATETIME,
  last_update_type STRING
)
;
