## Translation time: 2024-03-04T06:41:57.683170Z
## Translation job ID: 00dc6676-2c12-444a-b02a-71c7788bdc89
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/EDW_TRIPS/Tables/Stage_CustomerAdjustmentDetail.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_TRIPS_STAGE_APS.CustomerAdjustmentDetail
(
  adjlineitemid INT64 NOT NULL,
  adjustmentid INT64 NOT NULL,
  customerid INT64 NOT NULL,
  planid INT64 NOT NULL,
  customerplandesc STRING,
  customerpaymenttype STRING NOT NULL,
  apptxntypeid INT64,
  apptxntypecode STRING,
  apptxntypedesc STRING,
  customerpaymentlevelid INT64 NOT NULL,
  lineitemamount NUMERIC(31, 2),
  approvedstatusdate DATETIME NOT NULL,
  paymentmodeid INT64,
  paymentmodecode STRING,
  adjapprovalstatusid INT64 NOT NULL,
  drcrflag STRING,
  deleteflag INT64
) CLUSTER BY adjlineitemid
;