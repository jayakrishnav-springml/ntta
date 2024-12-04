-- Translation time: 2024-06-04T08:04:57.852399Z
-- Translation job ID: d189ef38-1420-4658-96a7-29624b482bd7
-- Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_LG_VPS/Tables/VP_OWNER_LB_XREF_ITEM_TYPES.sql
-- Translated from: SqlServer
-- Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_LG_VPS.Vp_Owner_Lb_Xref_Item_Types
(
  id NUMERIC(29) NOT NULL,
  item_type_code STRING NOT NULL,
  short_description STRING NOT NULL,
  long_description STRING NOT NULL,
  item_type_order BIGNUMERIC(48, 10) NOT NULL,
  is_active STRING NOT NULL,
  created_by STRING NOT NULL,
  date_created DATETIME NOT NULL,
  modified_by STRING NOT NULL,
  date_modified DATETIME NOT NULL,
  source_type_id BIGNUMERIC(48, 10) NOT NULL,
  is_displayable STRING NOT NULL,
  is_details_allowed STRING NOT NULL,
  last_update_date DATETIME,
  last_update_type STRING
)
;
