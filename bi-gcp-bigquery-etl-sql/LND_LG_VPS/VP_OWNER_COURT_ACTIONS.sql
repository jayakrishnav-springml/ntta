-- Translation time: 2024-06-04T08:04:57.852399Z
-- Translation job ID: d189ef38-1420-4658-96a7-29624b482bd7
-- Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_LG_VPS/Tables/VP_OWNER_COURT_ACTIONS.sql
-- Translated from: SqlServer
-- Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_LG_VPS.Vp_Owner_Court_Actions
(
  court_action_id NUMERIC(29) NOT NULL,
  court_id NUMERIC(29) NOT NULL,
  citation_nbr STRING,
  docket_nbr STRING,
  is_finalized STRING NOT NULL,
  court_act_status STRING NOT NULL,
  viol_date DATETIME,
  court_date DATETIME,
  court_time DATETIME,
  mail_date DATETIME,
  appearance_date DATETIME,
  prev_mail_date DATETIME,
  comment_date DATETIME,
  po_id NUMERIC(29) NOT NULL,
  created_by STRING NOT NULL,
  date_created DATETIME NOT NULL,
  modified_by STRING,
  date_modified DATETIME,
  plea_code STRING,
  disposition STRING NOT NULL,
  disposition_date DATETIME,
  final_charge STRING,
  cause_nbr NUMERIC(29),
  penalty_cost NUMERIC(31, 2),
  old_court_date DATETIME,
  jury_trial STRING,
  jp_court_file STRING NOT NULL,
  dps_citation_nbr STRING,
  last_update_type STRING NOT NULL,
  last_update_date DATETIME NOT NULL
)
cluster by court_action_id
;
