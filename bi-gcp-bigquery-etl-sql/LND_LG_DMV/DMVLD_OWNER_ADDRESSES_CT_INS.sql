-- Translation time: 2024-05-22T12:36:41.830310Z
-- Translation job ID: d3568ee0-99d8-46a7-93e2-5d48994c87d3
-- Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_LG_DMV/Tables/DMVLD_OWNER_ADDRESSES_CT_INS.sql
-- Translated from: SqlServer
-- Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_LG_DMV.Dmvld_Owner_Addresses_Ct_Ins
(
  id BIGNUMERIC(48, 10) NOT NULL,
  ownr_id NUMERIC(29) NOT NULL,
  plate_number STRING NOT NULL,
  vehi_id NUMERIC(29) NOT NULL,
  street STRING,
  city STRING,
  zip STRING,
  plus4 STRING,
  addr_state STRING NOT NULL,
  addr_start DATETIME,
  addr_end DATETIME,
  addr_comment STRING,
  status STRING,
  drec_id NUMERIC(29) NOT NULL,
  date_created DATETIME,
  date_modified DATETIME,
  modified_by STRING,
  created_by STRING,
  type STRING,
  insert_datetime DATETIME NOT NULL
)
;
