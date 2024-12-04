-- Translation time: 2024-06-04T07:59:17.388387Z
-- Translation job ID: 5118bff3-1545-4bd3-96b6-65be13aded87
-- Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_LG_ICRS/Tables/ICRS_OWNER_QA_REP_SUMM.sql
-- Translated from: SqlServer
-- Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_LG_ICRS.Icrs_Owner_Qa_Rep_Summ
(
  users STRING NOT NULL,
  user_name STRING NOT NULL,
  row_name DATETIME,
  img_reviewed BIGNUMERIC(48, 10),
  img_qa_checked BIGNUMERIC(48, 10),
  perc_qa_checked BIGNUMERIC(48, 10),
  pri_img_change BIGNUMERIC(48, 10),
  roi_img_change BIGNUMERIC(48, 10),
  lic_plate_change BIGNUMERIC(48, 10),
  lic_state_change BIGNUMERIC(48, 10),
  image_status_change BIGNUMERIC(48, 10),
  total_changed BIGNUMERIC(48, 10),
  perc_changed BIGNUMERIC(48, 10),
  perc_correct BIGNUMERIC(48, 10),
  date_created DATETIME,
  date_modified DATETIME,
  last_update_date DATETIME,
  last_update_type STRING
)
;
