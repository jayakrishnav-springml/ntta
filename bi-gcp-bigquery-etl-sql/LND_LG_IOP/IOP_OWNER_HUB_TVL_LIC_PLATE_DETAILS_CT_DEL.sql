-- Translation time: 2024-06-04T08:01:15.437249Z
-- Translation job ID: a14a1a7f-7d63-47c9-8296-0b7483d5c271
-- Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_LG_IOP/Tables/IOP_OWNER_HUB_TVL_LIC_PLATE_DETAILS_CT_DEL.sql
-- Translated from: SqlServer
-- Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_LG_IOP.Iop_Owner_Hub_Tvl_Lic_Plate_Details_Ct_Del
(
  hub_tvl_lic_plate_detail_id FLOAT64 NOT NULL,
  hub_tvl_tag_detail_id FLOAT64,
  iop_home_agency_id STRING,
  iop_sent_to_agency_id STRING,
  tag_agency_id STRING,
  tag_serial_number STRING,
  lic_plate_country STRING,
  lic_plate_state STRING,
  lic_plate_number STRING,
  lic_plate_eff_from DATETIME,
  lic_plate_eff_to DATETIME,
  lic_plate_type STRING,
  created_by STRING NOT NULL,
  date_created DATETIME NOT NULL,
  modified_by STRING NOT NULL,
  date_modified DATETIME NOT NULL,
  insert_datetime DATETIME NOT NULL
)
;
