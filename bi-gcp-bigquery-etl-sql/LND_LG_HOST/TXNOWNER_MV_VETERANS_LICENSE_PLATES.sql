-- Translation time: 2024-06-04T07:57:18.317878Z
-- Translation job ID: b2abff43-eccf-406a-aa5d-053048797d89
-- Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_LG_HOST/Tables/TXNOWNER_MV_VETERANS_LICENSE_PLATES.sql
-- Translated from: SqlServer
-- Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_LG_HOST.TxnOwner_Mv_Veterans_License_Plates
(
  lic_plate_state STRING,
  lic_plate_nbr STRING,
  start_date DATETIME,
  end_date DATETIME,
  last_update_type STRING NOT NULL,
  last_update_date DATETIME NOT NULL
)
;
