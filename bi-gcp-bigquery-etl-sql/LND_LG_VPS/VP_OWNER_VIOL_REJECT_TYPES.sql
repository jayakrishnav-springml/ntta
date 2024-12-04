-- Translation time: 2024-06-04T08:04:57.852399Z
-- Translation job ID: d189ef38-1420-4658-96a7-29624b482bd7
-- Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_LG_VPS/Tables/VP_OWNER_VIOL_REJECT_TYPES.sql
-- Translated from: SqlServer
-- Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_LG_VPS.Vp_Owner_Viol_Reject_Types
(
  viol_reject_type STRING NOT NULL,
  viol_reject_type_descr STRING NOT NULL,
  viol_reject_type_order NUMERIC(29),
  viol_reject_type_role_level NUMERIC(29),
  supervisor_only STRING,
  is_active STRING NOT NULL,
  is_closed STRING,
  date_created DATE NOT NULL,
  created_by STRING NOT NULL,
  date_modified DATE,
  modified_by STRING,
  tsa_reject_code STRING,
  send_to_tsa STRING NOT NULL,
  last_update_type STRING NOT NULL,
  last_update_date DATETIME NOT NULL
)
;
