## Translation time: 2024-03-13T05:19:34.327071Z
## Translation job ID: 0a711804-adbe-4db7-8cda-d8808bd4ce52
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/NTTA_Missing_DDLs/EDW_TRIPS_Temp_Fact_UnifiedTransaction_Summary_20240107.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_TRIPS_APS.Fact_UnifiedTransaction_Summary_20240107
(
  tripdayid INT64 NOT NULL,
  laneid INT64,
  operationsmappingid INT64,
  tripwith STRING,
  sourceofentry INT64,
  tripidentmethodid INT64,
  lanetripidentmethodid INT64 NOT NULL,
  recordtypeid INT64 NOT NULL,
  transactionpostingtypeid INT64,
  tripstageid INT64,
  tripstatusid INT64,
  reasoncodeid INT64,
  citationstageid INT64,
  trippaymentstatusid INT64,
  vehicleclassid INT64,
  badaddressflag INT64,
  nonrevenueflag INT64,
  businessrulematchedflag INT64,
  manuallyreviewedflag INT64 NOT NULL,
  oosplateflag INT64 NOT NULL,
  vtollflag INT64,
  classadjustmentflag INT64 NOT NULL,
  rpt_paidvsaea STRING,
  firstpaiddate DATE,
  lastpaiddate DATE,
  txncount INT64,
  expectedamount NUMERIC(31, 2),
  adjustedexpectedamount NUMERIC(31, 2),
  calcadjustedamount NUMERIC(31, 2),
  tripwithadjustedamount NUMERIC(31, 2),
  tollamount NUMERIC(31, 2),
  actualpaidamount NUMERIC(31, 2),
  outstandingamount NUMERIC(31, 2),
  lnd_updatedate DATETIME,
  edw_updatedate DATETIME
)
;