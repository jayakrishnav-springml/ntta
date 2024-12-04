-- Translation time: 2024-06-04T08:01:15.437249Z
-- Translation job ID: a14a1a7f-7d63-47c9-8296-0b7483d5c271
-- Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_LG_IOP/Tables/IOP_OWNER_HUB_IOP_DISPOSITIONS.sql
-- Translated from: SqlServer
-- Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_LG_IOP.Iop_Owner_Hub_Iop_Dispositions
(
  disposition STRING NOT NULL,
  disp_short_descr STRING NOT NULL,
  disp_descr STRING NOT NULL,
  order_by INT64,
  is_active STRING NOT NULL,
  date_created DATETIME NOT NULL,
  created_by STRING NOT NULL,
  date_modified DATETIME NOT NULL,
  modified_by STRING NOT NULL,
  last_update_date DATETIME,
  last_update_type STRING
)
;