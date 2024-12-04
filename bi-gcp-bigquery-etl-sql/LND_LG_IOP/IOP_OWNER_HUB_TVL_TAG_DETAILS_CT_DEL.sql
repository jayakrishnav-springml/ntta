-- Translation time: 2024-06-04T08:01:15.437249Z
-- Translation job ID: a14a1a7f-7d63-47c9-8296-0b7483d5c271
-- Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_LG_IOP/Tables/IOP_OWNER_HUB_TVL_TAG_DETAILS_CT_DEL.sql
-- Translated from: SqlServer
-- Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_LG_IOP.Iop_Owner_Hub_Tvl_Tag_Details_Ct_Del
(
  hub_tvl_tag_detail_id BIGNUMERIC(38) NOT NULL,
  hub_id STRING,
  iop_home_agency_id STRING,
  iop_sent_to_agency_id STRING,
  tag_agency_id STRING,
  tag_serial_number STRING,
  tag_status STRING,
  discount_plans STRING,
  tag_type STRING,
  tag_class BIGNUMERIC(38),
  account_number STRING,
  fleet_indicator STRING,
  effective_batch_id BIGNUMERIC(38),
  batch_mode STRING NOT NULL,
  date_tvl_effective DATETIME,
  created_by STRING NOT NULL,
  date_created DATETIME NOT NULL,
  modified_by STRING NOT NULL,
  date_modified DATETIME NOT NULL,
  insert_datetime DATETIME NOT NULL
)
;
