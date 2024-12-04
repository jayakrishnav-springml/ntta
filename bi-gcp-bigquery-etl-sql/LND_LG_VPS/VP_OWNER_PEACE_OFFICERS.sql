-- Translation time: 2024-06-04T08:04:57.852399Z
-- Translation job ID: d189ef38-1420-4658-96a7-29624b482bd7
-- Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_LG_VPS/Tables/VP_OWNER_PEACE_OFFICERS.sql
-- Translated from: SqlServer
-- Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_LG_VPS.Vp_Owner_Peace_Officers
(
  po_id INT64 NOT NULL,
  po_fname STRING NOT NULL,
  po_lname STRING NOT NULL,
  po_emp_id INT64 NOT NULL,
  po_signature_loc STRING,
  po_signature_active STRING NOT NULL,
  region STRING,
  district STRING,
  area STRING,
  default_po_ind STRING NOT NULL,
  date_created DATETIME NOT NULL,
  created_by STRING NOT NULL,
  date_modified DATETIME,
  modified_by STRING,
  effective_date DATETIME,
  retired_date DATETIME,
  last_update_date DATETIME,
  last_update_type STRING
)
;
