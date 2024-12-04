-- Translation time: 2024-06-04T08:04:57.852399Z
-- Translation job ID: d189ef38-1420-4658-96a7-29624b482bd7
-- Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_LG_VPS/Tables/VP_OWNER_RECEIPT_DETAILS.sql
-- Translated from: SqlServer
-- Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_LG_VPS.Vp_Owner_Receipt_Details
(
  vtoll_detail_id STRING NOT NULL,
  receipt_id NUMERIC(29) NOT NULL,
  viol_invoice_id NUMERIC(29),
  violation_id BIGNUMERIC(48, 10),
  vtoll_amt NUMERIC(31, 2) NOT NULL,
  date_created DATETIME NOT NULL,
  modified_by STRING NOT NULL,
  created_by STRING NOT NULL,
  date_modified DATETIME NOT NULL,
  vbi_invoice_id NUMERIC(29),
  last_update_type STRING,
  last_update_date DATETIME
)
;
