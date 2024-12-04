## Translation time: 2024-03-04T06:41:57.683170Z
## Translation job ID: 00dc6676-2c12-444a-b02a-71c7788bdc89
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/EDW_TRIPS/Tables/Stage_DismissedVToll.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_TRIPS_STAGE_APS.DismissedVToll
(
  invoicenumber STRING,
  totaltxncnt INT64,
  vtolltxncnt INT64,
  unassignedtxncnt INT64,
  unassignedvtolledtxncnt INT64 NOT NULL,
  vtollpaidtxncnt INT64,
  firstpaymentdate DATETIME,
  lastpaymentdate DATETIME,
  tolls BIGNUMERIC(40, 2),
  pbmtollamount BIGNUMERIC(40, 2),
  avitollamount BIGNUMERIC(40, 2),
  premiumamount BIGNUMERIC(40, 2),
  paidamount_vt BIGNUMERIC(40, 2),
  tollsadjusted BIGNUMERIC(40, 2),
  tollsadjustedaftervtoll INT64 NOT NULL,
  adjustedamount_excused INT64 NOT NULL,
  classadj INT64 NOT NULL,
  outstandingamount BIGNUMERIC(40, 2),
  paidtnxs INT64 NOT NULL,
  vtollflag INT64 NOT NULL,
  vtollflagdescription STRING NOT NULL,
  edw_update_date TIMESTAMP NOT NULL
)
;