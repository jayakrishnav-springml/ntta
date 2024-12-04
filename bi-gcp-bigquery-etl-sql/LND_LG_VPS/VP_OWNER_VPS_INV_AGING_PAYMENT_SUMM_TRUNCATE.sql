-- Translation time: 2024-06-04T08:04:57.852399Z
-- Translation job ID: d189ef38-1420-4658-96a7-29624b482bd7
-- Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_LG_VPS/Tables/VP_OWNER_VPS_INV_AGING_PAYMENT_SUMM_TRUNCATE.sql
-- Translated from: SqlServer
-- Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_LG_VPS.Vp_Owner_Vps_Inv_Aging_Payment_Summ_Truncate
(
  inv_date DATETIME NOT NULL,
  viol_source STRING NOT NULL,
  inv_count INT64 NOT NULL,
  inv_rev NUMERIC(33, 4) NOT NULL,
  zc_count INT64 NOT NULL,
  zc_rev NUMERIC(33, 4) NOT NULL,
  ln_count INT64 NOT NULL,
  ln_rev NUMERIC(33, 4) NOT NULL,
  ln_fee NUMERIC(33, 4) NOT NULL,
  vps_count INT64 NOT NULL,
  vps_rev NUMERIC(33, 4) NOT NULL,
  vps_fine NUMERIC(33, 4) NOT NULL,
  col_count INT64 NOT NULL,
  col_rev NUMERIC(33, 4) NOT NULL,
  col_fine NUMERIC(33, 4) NOT NULL,
  dps_count INT64 NOT NULL,
  dps_rev NUMERIC(33, 4) NOT NULL,
  dps_fine NUMERIC(33, 4) NOT NULL,
  open_count INT64 NOT NULL,
  open_rev NUMERIC(33, 4) NOT NULL,
  open_fine NUMERIC(33, 4) NOT NULL,
  uc_zc_count INT64 NOT NULL,
  uc_zc_rev NUMERIC(33, 4) NOT NULL,
  uc_ln_count INT64 NOT NULL,
  uc_ln_rev NUMERIC(33, 4) NOT NULL,
  uc_ln_fee NUMERIC(33, 4) NOT NULL,
  uc_vps_count INT64 NOT NULL,
  uc_vps_rev NUMERIC(33, 4) NOT NULL,
  uc_vps_fine NUMERIC(33, 4) NOT NULL,
  uc_col_count INT64 NOT NULL,
  uc_col_rev NUMERIC(33, 4) NOT NULL,
  uc_col_fine NUMERIC(33, 4) NOT NULL,
  uc_dps_count INT64 NOT NULL,
  uc_dps_rev NUMERIC(33, 4) NOT NULL,
  uc_dps_fine NUMERIC(33, 4) NOT NULL,
  date_created DATETIME NOT NULL,
  created_by STRING NOT NULL,
  vps_admin_fee NUMERIC(33, 4),
  uc_vps_admin_fee NUMERIC(33, 4),
  vps_admin_fee2 NUMERIC(33, 4),
  uc_vps_admin_fee2 NUMERIC(33, 4),
  col_admin_fee NUMERIC(33, 4),
  uc_col_admin_fee NUMERIC(33, 4),
  col_admin_fee2 NUMERIC(33, 4),
  uc_col_admin_fee2 NUMERIC(33, 4),
  dps_admin_fee NUMERIC(33, 4),
  uc_dps_admin_fee NUMERIC(33, 4),
  dps_admin_fee2 NUMERIC(33, 4),
  uc_dps_admin_fee2 NUMERIC(33, 4),
  last_update_type STRING NOT NULL,
  last_update_date DATETIME NOT NULL
)
cluster by inv_date
;
