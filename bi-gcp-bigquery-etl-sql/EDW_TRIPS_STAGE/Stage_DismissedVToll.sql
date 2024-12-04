-- Translation time: 2024-07-11T07:10:16.441155Z
-- Translation job ID: 01f97d19-b914-463a-8c9e-73c23536d6e1
-- Source: gs://ntta-gcp-poc-source-code-scripts/transpiled_ddl_tmp/ITEM_90_NEW_APS/Stage.DismissedVToll.dsql
-- Translated from: SqlServer
-- Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_TRIPS_STAGE.DismissedVToll
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
  edw_update_date DATETIME NOT NULL
)
;
