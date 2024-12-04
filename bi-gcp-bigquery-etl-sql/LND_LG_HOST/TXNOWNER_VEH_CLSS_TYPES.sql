-- Translation time: 2024-06-04T07:57:18.317878Z
-- Translation job ID: b2abff43-eccf-406a-aa5d-053048797d89
-- Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_LG_HOST/Tables/TXNOWNER_VEH_CLSS_TYPES.sql
-- Translated from: SqlServer
-- Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_LG_HOST.TxnOwner_Veh_Clss_Types
(
  vcly_desc STRING NOT NULL,
  note STRING,
  axles INT64 NOT NULL,
  created_by STRING NOT NULL,
  creation_date DATETIME NOT NULL,
  updated_by STRING NOT NULL,
  updated_date DATETIME NOT NULL,
  vcly_id NUMERIC(29) NOT NULL,
  vehy_id NUMERIC(29) NOT NULL,
  displayed STRING NOT NULL,
  vcly_order INT64 NOT NULL,
  last_update_date DATETIME,
  last_update_type STRING
)
cluster by vcly_id
;
