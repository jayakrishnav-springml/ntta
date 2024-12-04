-- Translation time: 2024-06-04T08:04:57.852399Z
-- Translation job ID: d189ef38-1420-4658-96a7-29624b482bd7
-- Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_LG_VPS/Tables/VP_OWNER_CA_ACCT_COMMENTS.sql
-- Translated from: SqlServer
-- Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_LG_VPS.Vp_Owner_Ca_Acct_Comments
(
  ca_acct_id NUMERIC(29) NOT NULL,
  ca_acct_id_seq INT64 NOT NULL,
  ca_acct_comment STRING NOT NULL,
  comment_date DATETIME NOT NULL,
  created_by STRING NOT NULL,
  date_created DATETIME NOT NULL,
  date_modified DATETIME,
  modified_by STRING,
  last_update_date DATETIME,
  last_update_type STRING
)
;
