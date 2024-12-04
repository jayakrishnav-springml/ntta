-- Translation time: 2024-06-04T08:01:15.437249Z
-- Translation job ID: a14a1a7f-7d63-47c9-8296-0b7483d5c271
-- Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_LG_IOP/Tables/IOP_OWNER_TVL_TAG_DETAILS_CT_INS.sql
-- Translated from: SqlServer
-- Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_LG_IOP.Iop_Owner_Tvl_Tag_Details_Ct_Ins
(
  ttd_id NUMERIC(29) NOT NULL,
  hia_agcy_id NUMERIC(29) NOT NULL,
  tag_identifier STRING NOT NULL,
  tag_id STRING NOT NULL,
  tvl_agcy_id NUMERIC(29) NOT NULL,
  batch_mode STRING NOT NULL,
  tvl_tag_status STRING NOT NULL,
  lic_plate_nbr STRING,
  lic_plate_state STRING,
  vehicle_class_code INT64 NOT NULL,
  rev_type INT64 NOT NULL,
  first_tvl_batch_id NUMERIC(29) NOT NULL,
  date_tvl_effective DATETIME NOT NULL,
  last_tvl_batch_id NUMERIC(29) NOT NULL,
  attribute_1 STRING,
  attribute_2 STRING,
  attribute_3 STRING,
  attribute_4 STRING,
  attribute_5 STRING,
  created_by STRING NOT NULL,
  date_created DATETIME NOT NULL,
  modified_by STRING NOT NULL,
  date_modified DATETIME NOT NULL,
  insert_datetime DATETIME NOT NULL
)
;
