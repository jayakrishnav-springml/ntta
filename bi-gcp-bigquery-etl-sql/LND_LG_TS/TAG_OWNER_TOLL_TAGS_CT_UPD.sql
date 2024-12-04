-- Translation time: 2024-06-04T08:03:02.538216Z
-- Translation job ID: 2ee163b6-d1ed-4585-9295-ffd9f05ba970
-- Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_LG_TS/Tables/TAG_OWNER_TOLL_TAGS_CT_UPD.sql
-- Translated from: SqlServer
-- Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_LG_TS.Tag_Owner_Toll_Tags_Ct_Upd
(
  agency_id STRING NOT NULL,
  tag_id STRING NOT NULL,
  tag_status STRING NOT NULL,
  last_read_loc STRING,
  last_read_date DATETIME,
  tag_type_code STRING NOT NULL,
  owner_agency STRING NOT NULL,
  pos_id INT64 NOT NULL,
  insert_datetime DATETIME NOT NULL
)
;
