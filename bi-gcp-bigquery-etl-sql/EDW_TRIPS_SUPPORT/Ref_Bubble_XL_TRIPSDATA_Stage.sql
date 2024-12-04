## Translation time: 2024-03-04T06:41:57.683170Z
## Translation job ID: 00dc6676-2c12-444a-b02a-71c7788bdc89
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/EDW_TRIPS/Tables/Ref_Bubble_XL_TRIPSDATA_Stage.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_TRIPS_SUPPORT.Bubble_XL_TRIPSDATA_Stage
(
  snapshotmonthid INT64 NOT NULL,
  asofdayid INT64,
  tripmonthid INT64 NOT NULL,
  facilityid INT64 NOT NULL,
  facilitycode STRING,
  operationsagency STRING NOT NULL,
  mapping STRING,
  mappingdetailed STRING,
  pursunpursstatus STRING,
  tripidentmethod STRING,
  recordtype STRING,
  tripwith STRING,
  transactionpostingtype STRING,
  tripstageid INT64,
  tripstagecode STRING,
  tripstagedesc STRING,
  tripstatusid INT64,
  tripstatuscode STRING,
  tripstatusdesc STRING,
  reasoncode STRING,
  citationstagecode STRING,
  trippaymentstatusdesc STRING,
  sourcename STRING,
  nonrevenueflag INT64,
  badaddressflag INT64,
  businessrulematchedflag INT64,
  oosplateflag INT64,
  manuallyreviewedflag INT64,
  firstpaidmonthid INT64 NOT NULL,
  lastpaidmonthid INT64 NOT NULL,
  txncount INT64,
  expectedamount NUMERIC(31, 2),
  adjustedexpectedamount NUMERIC(31, 2),
  actualpaidamount NUMERIC(31, 2),
  calcadjustedamount NUMERIC(31, 2),
  outstandingamount NUMERIC(31, 2),
  tripwithadjustedamount NUMERIC(31, 2),
  tollamount NUMERIC(31, 2),
  rpt_paidvsaea STRING NOT NULL,
  rpt_purunp STRING NOT NULL,
  rpt_lpstate STRING NOT NULL,
  rpt_invuninv STRING NOT NULL,
  rpt_vtoll STRING NOT NULL,
  rpt_irstatus STRING NOT NULL,
  rpt_processstatus STRING NOT NULL,
  rpt_paidstatus STRING NOT NULL,
  rpt_irrejectstatus STRING NOT NULL,
  edw_updatedate DATETIME
)
;