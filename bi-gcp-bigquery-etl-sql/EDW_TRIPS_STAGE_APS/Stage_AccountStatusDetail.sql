## Translation time: 2024-03-04T06:41:57.683170Z
## Translation job ID: 00dc6676-2c12-444a-b02a-71c7788bdc89
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/EDW_TRIPS/Tables/Stage_AccountStatusDetail.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_TRIPS_STAGE_APS.AccountStatusDetail 
(
  customerid INT64 NOT NULL,
  regcustrefid INT64 NOT NULL,
  usertypeid INT64,
  accountcreatedate DATETIME,
  accountcreatedby STRING,
  accountcreatechannelid INT64,
  accountcreatechannelname STRING,
  accountcreatechanneldesc STRING,
  accountcreateposid INT64,
  accountopendate DATETIME,
  accountopenedby STRING,
  accountopenchannelid INT64,
  accountopenchannelname STRING,
  accountopenchanneldesc STRING,
  accountopenposid INT64,
  accountlastactivedate DATETIME,
  accountlastactiveby STRING,
  accountlastactivechannelid INT64,
  accountlastactivechannelname STRING,
  accountlastactivechanneldesc STRING,
  accountlastactiveposid INT64,
  accountlastclosedate DATETIME,
  accountlastcloseby STRING,
  accountlastclosechannelid INT64,
  accountlastclosechannelname STRING,
  accountlastclosechanneldesc STRING,
  accountlastcloseposid INT64
) CLUSTER BY customerid
;