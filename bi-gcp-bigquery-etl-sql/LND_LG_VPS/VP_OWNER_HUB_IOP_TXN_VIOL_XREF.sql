-- Translation time: 2024-06-04T08:04:57.852399Z
-- Translation job ID: d189ef38-1420-4658-96a7-29624b482bd7
-- Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_LG_VPS/Tables/VP_OWNER_HUB_IOP_TXN_VIOL_XREF.sql
-- Translated from: SqlServer
-- Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_LG_VPS.Vp_Owner_Hub_Iop_Txn_Viol_Xref
(
  txn_viol_xref_id BIGNUMERIC(38) NOT NULL,
  iop_away_agency_id STRING NOT NULL,
  txn_reference_id BIGNUMERIC(38) NOT NULL,
  hub_iop_txn_id BIGNUMERIC(38) NOT NULL,
  violation_id BIGNUMERIC(38) NOT NULL,
  created_by STRING,
  date_created DATETIME,
  modified_by STRING,
  date_modified DATETIME,
  last_update_date DATETIME,
  last_update_type STRING
)
;
