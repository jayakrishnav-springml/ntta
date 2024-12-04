## Translation time: 2024-03-04T06:41:57.683170Z
## Translation job ID: 00dc6676-2c12-444a-b02a-71c7788bdc89
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/EDW_TRIPS/Tables/Ref_Bubble_XL_TRIPSDATA_Source_BKUP.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_TRIPS_SUPPORT.Bubble_XL_TRIPSDATA_Source_BKUP
(
  snapshotmonthid INT64 NOT NULL,
  `txnyr mnth` INT64 NOT NULL,
  facility STRING,
  agency STRING,
  operationsmappingid INT64,
  mapping STRING,
  mapping_detailed STRING,
  purs_unpurs_calc STRING,
  tripidentmethod STRING,
  sourcename STRING,
  isiopduplicate INT64,
  tripwith STRING,
  transactionpostingtype STRING,
  tripstageid INT64,
  tripstagecode STRING,
  tripstagedescription STRING,
  tripstatusid INT64,
  tripstatuscode STRING,
  tripstatusdescription STRING,
  reasoncode STRING,
  isnonrevenue INT64,
  citationstage STRING,
  paymentstatus STRING,
  badaddress STRING,
  isoosplate STRING,
  isbusinessrulematched STRING,
  ismanuallyreviewed STRING,
  txncount INT64,
  expectedamount NUMERIC(31, 2),
  adjexpamt NUMERIC(31, 2),
  paidamount NUMERIC(31, 2),
  firstpaidmonthid INT64,
  lastpaidmonthid INT64,
  calcadjustedamount NUMERIC(31, 2),
  outstandingamount NUMERIC(31, 2),
  tripwithadjustedamount NUMERIC(31, 2),
  tollamount NUMERIC(31, 2),
  rpt_paidvsaea STRING,
  rpt_lpstate STRING,
  rpt_invuninv STRING,
  rpt_vtoll STRING,
  rpt_purunp STRING,
  rpt_irstatus STRING,
  rpt_processstatus STRING,
  rpt_paidstatus STRING,
  rpt_irrejectstatus STRING,
  recordtype STRING
)
;