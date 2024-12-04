## Translation time: 2024-03-21T20:56:06.764423Z
## Translation job ID: e212c5d3-a7fa-4886-93b1-cb3be341e70a
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/EDW_RITE/Tables/dbo_FACT_VIOLATIONS_DMV_STATUS_DETAIL_HIST.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_RITE.Fact_Violations_Dmv_Status_Detail_Hist
(
  partition_date DATE,
  violation_id BIGNUMERIC(48, 10) NOT NULL,
  day_id STRING,
  lane_id NUMERIC(29) NOT NULL,
  vcly_id NUMERIC(29) NOT NULL,
  vehicle_class NUMERIC(29) NOT NULL,
  dmv_sts STRING,
  business_type STRING,
  lic_plate_nbr STRING NOT NULL,
  lic_plate_state STRING NOT NULL,
  toll_due NUMERIC(31, 2) NOT NULL,
  toll_paid NUMERIC(31, 2) NOT NULL
)
;
