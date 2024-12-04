-- Translation time: 2024-05-22T12:36:41.830310Z
-- Translation job ID: d3568ee0-99d8-46a7-93e2-5d48994c87d3
-- Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_LG_DMV/Tables/DMVLD_VO_RENEWAL_ADDR_XREF.sql
-- Translated from: SqlServer
-- Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_LG_DMV.Dmvld_Vo_Renewal_Addr_Xref
(
  id NUMERIC(29) NOT NULL,
  vehi_id NUMERIC(29) NOT NULL,
  ownr_id NUMERIC(29) NOT NULL,
  rcpt_ownr_id NUMERIC(29) NOT NULL,
  addr_id NUMERIC(29) NOT NULL,
  addr_start DATETIME NOT NULL,
  addr_end DATETIME,
  is_current STRING NOT NULL,
  created_by STRING NOT NULL,
  date_created DATETIME NOT NULL,
  modified_by STRING NOT NULL,
  date_modified DATETIME NOT NULL,
  source_id NUMERIC(29) NOT NULL,
  end_source_id NUMERIC(29),
  source_code STRING,
  end_source_code STRING,
  last_update_date DATETIME,
  last_update_type STRING
)
;
