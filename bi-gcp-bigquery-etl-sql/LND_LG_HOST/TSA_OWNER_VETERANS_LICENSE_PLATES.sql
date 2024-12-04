-- Translation time: 2024-06-04T07:57:18.317878Z
-- Translation job ID: b2abff43-eccf-406a-aa5d-053048797d89
-- Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_LG_HOST/Tables/TSA_OWNER_VETERANS_LICENSE_PLATES.sql
-- Translated from: SqlServer
-- Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_LG_HOST.Tsa_Owner_Veterans_License_Plates
(
  veteran_lic_plate_id BIGNUMERIC(48, 10) NOT NULL,
  lic_plate_state STRING NOT NULL,
  lic_plate_nbr STRING NOT NULL,
  start_date DATETIME NOT NULL,
  end_date DATETIME NOT NULL,
  created_date DATETIME NOT NULL,
  created_by STRING NOT NULL,
  modified_date DATETIME NOT NULL,
  modified_by STRING NOT NULL,
  last_update_date DATETIME,
  last_update_type STRING
)
;
