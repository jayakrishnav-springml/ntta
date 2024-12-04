## Translation time: 2024-03-04T06:41:57.683170Z
## Translation job ID: 00dc6676-2c12-444a-b02a-71c7788bdc89
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/EDW_TRIPS/Tables/dbo_Fact_UnifiedTransaction_SummarySnapshot.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_TRIPS_APS.Fact_UnifiedTransaction_SummarySnapshot
(
  snapshotmonthid INT64,
  asofdayid INT64,
  rowseq INT64,
  tripmonthid INT64,
  facilityid INT64,
  facilitycode STRING,
  operationsagency STRING NOT NULL,
  operationsmappingid INT64,
  mapping STRING,
  mappingdetailed STRING,
  pursunpursstatus STRING,
  tripwith STRING,
  tripidentmethodid INT64,
  recordtypeid INT64 NOT NULL,
  transactionpostingtypeid INT64,
  tripstageid INT64,
  tripstatusid INT64,
  reasoncodeid INT64,
  citationstageid INT64,
  trippaymentstatusid INT64,
  sourcename STRING,
  badaddressflag INT64,
  nonrevenueflag INT64,
  businessrulematchedflag INT64,
  manuallyreviewedflag INT64,
  oosplateflag INT64,
  vtollflag INT64,
  classadjustmentflag INT64,
  firstpaidmonthid INT64 NOT NULL,
  lastpaidmonthid INT64 NOT NULL,
  rpt_paidvsaea STRING,
  rpt_purunp STRING,
  rpt_lpstate STRING,
  rpt_invuninv STRING,
  rpt_vtoll STRING,
  rpt_irstatus STRING,
  rpt_processstatus STRING,
  rpt_paidstatus STRING,
  rpt_irrejectstatus STRING,
  txncount INT64,
  expectedamount NUMERIC(31, 2),
  adjustedexpectedamount NUMERIC(31, 2),
  calcadjustedamount NUMERIC(31, 2),
  tripwithadjustedamount NUMERIC(31, 2),
  tollamount NUMERIC(31, 2),
  actualpaidamount NUMERIC(31, 2),
  outstandingamount NUMERIC(31, 2),
  lnd_updatedate DATETIME,
  edw_updatedate TIMESTAMP
)
cluster by snapshotmonthid
;