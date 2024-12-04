-- Translation time: 2024-06-04T08:04:57.852399Z
-- Translation job ID: d189ef38-1420-4658-96a7-29624b482bd7
-- Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_LG_VPS/Tables/VP_OWNER_COURT_ACT_VIOL.sql
-- Translated from: SqlServer
-- Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_LG_VPS.Vp_Owner_Court_Act_Viol
(
  court_action_id INT64 NOT NULL,
  viol_invoice_id NUMERIC(29) NOT NULL,
  violation_id FLOAT64 NOT NULL,
  fine_amount NUMERIC(33, 4),
  last_update_type STRING NOT NULL,
  last_update_date DATETIME NOT NULL
)
cluster by viol_invoice_id
;
