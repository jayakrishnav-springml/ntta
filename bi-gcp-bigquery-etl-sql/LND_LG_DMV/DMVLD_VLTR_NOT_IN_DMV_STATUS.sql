-- Translation time: 2024-05-22T12:36:41.830310Z
-- Translation job ID: d3568ee0-99d8-46a7-93e2-5d48994c87d3
-- Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_LG_DMV/Tables/DMVLD_VLTR_NOT_IN_DMV_STATUS.sql
-- Translated from: SqlServer
-- Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_LG_DMV.Dmvld_Vltr_Not_In_Dmv_Status
(
  id BIGNUMERIC(48, 10) NOT NULL,
  status_id STRING NOT NULL,
  status_descr STRING NOT NULL,
  last_update_date DATETIME,
  last_update_type STRING
)
;
