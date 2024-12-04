-- Translation time: 2024-06-04T08:04:57.852399Z
-- Translation job ID: d189ef38-1420-4658-96a7-29624b482bd7
-- Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_LG_VPS/Tables/dbo_AET_FV_REPORT.sql
-- Translated from: SqlServer
-- Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_LG_VPS.Aet_Fv_Report
(
  agency_abbr STRING,
  variance_id STRING,
  txn_date DATETIME,
  lic_plate STRING,
  lic_state STRING,
  pymt_date DATETIME,
  facility STRING,
  facility_name STRING,
  plaza STRING,
  plaza_name STRING,
  lane_name STRING,
  amt_avi STRING,
  amt_video STRING,
  `diff _u0028_a-b_u0029_` STRING,
  amt_sub STRING,
  var_fee_avi STRING,
  var_fee_video STRING,
  `diff_fee _u0028_f-e_u0029_` STRING
)
;
