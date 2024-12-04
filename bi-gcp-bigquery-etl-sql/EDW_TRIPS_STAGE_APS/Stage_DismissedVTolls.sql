## Translation time: 2024-03-04T06:41:57.683170Z
## Translation job ID: 00dc6676-2c12-444a-b02a-71c7788bdc89
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/EDW_TRIPS/Tables/Stage_DismissedVTolls.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_TRIPS_STAGE_APS.DismissedVTolls
(
  invoicenumber STRING,
  citationtotal INT64,
  citationid_vtoll INT64,
  unassignedtxncnt INT64,
  firstpaymentdate DATETIME,
  lastpaymentdate DATETIME,
  paidamount_vt BIGNUMERIC(40, 2),
  tollsadjusted BIGNUMERIC(40, 2),
  tollsadjustedaftervtoll BIGNUMERIC(42, 4),
  adjustedamount_excused INT64 NOT NULL,
  classadj BIGNUMERIC(40, 2),
  outstandingamount BIGNUMERIC(40, 2),
  paidtnxs INT64,
  vtollflag INT64 NOT NULL,
  vtollflagdescription STRING NOT NULL,
  edw_update_date TIMESTAMP NOT NULL
)
;