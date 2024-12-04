-- Translation time: 2024-06-04T07:59:17.388387Z
-- Translation job ID: 5118bff3-1545-4bd3-96b6-65be13aded87
-- Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_LG_ICRS/Tables/ICRS_OWNER_REVIEW_SUMMARIES.sql
-- Translated from: SqlServer
-- Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_LG_ICRS.Icrs_Owner_Review_Summaries
(
  rvs_id NUMERIC(29) NOT NULL,
  ap_user_id BIGNUMERIC(38) NOT NULL,
  images_reviewed BIGNUMERIC(38),
  lre_created BIGNUMERIC(38),
  qa_images_reviewed BIGNUMERIC(38),
  date_created DATETIME,
  date_modified DATETIME,
  modified_by STRING,
  created_by STRING,
  summ_date DATETIME NOT NULL,
  summary_type STRING NOT NULL,
  last_update_date DATETIME,
  last_update_type STRING
)
;
