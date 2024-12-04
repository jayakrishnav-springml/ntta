## Translation time: 2024-03-04T06:41:57.683170Z
## Translation job ID: 00dc6676-2c12-444a-b02a-71c7788bdc89
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/EDW_TRIPS/Tables/Temp_Fact_UnifiedTransaction_SummarySnapshot_BKUP_B4_XL.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_TRIPS_APS.Fact_UnifiedTransaction_SummarySnapshot_BKUP_B4_XL
(
  snapshotmonthid INT64 NOT NULL,
  asofdayid INT64 NOT NULL,
  tripmonthid INT64 NOT NULL,
  facilitycode STRING,
  operationsagency STRING NOT NULL,
  operationsmappingid INT64 NOT NULL,
  mapping STRING NOT NULL,
  mappingdetailed STRING NOT NULL,
  pursunpursstatus STRING NOT NULL,
  tripwith STRING,
  tripidentmethodid INT64,
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
  facilityid INT64,
  recordtypeid INT64 NOT NULL,
  firstpaidmonthid INT64 NOT NULL,
  lastpaidmonthid INT64 NOT NULL,
  rpt_paidvsaea STRING,
  rpt_purunp STRING NOT NULL,
  rpt_lpstate STRING,
  rpt_invuninv STRING NOT NULL,
  rpt_vtoll STRING NOT NULL,
  rpt_irstatus STRING NOT NULL,
  rpt_processstatus STRING NOT NULL,
  rpt_paidstatus STRING NOT NULL,
  rpt_irrejectstatus STRING NOT NULL,
  txncount INT64,
  expectedamount NUMERIC(31, 2),
  adjustedexpectedamount NUMERIC(31, 2),
  calcadjustedamount NUMERIC(31, 2),
  tripwithadjustedamount NUMERIC(31, 2),
  tollamount NUMERIC(31, 2),
  actualpaidamount NUMERIC(31, 2),
  outstandingamount NUMERIC(31, 2),
  lnd_updatedate DATETIME,
  edw_updatedate TIMESTAMP,
  backupdate DATETIME
)CLUSTER BY snapshotmonthid
;