## Translation time: 2024-03-04T06:41:57.683170Z
## Translation job ID: 00dc6676-2c12-444a-b02a-71c7788bdc89
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/EDW_TRIPS/Tables/dbo_Dim_Customer.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_TRIPS_APS.Dim_Customer
(
  customerid INT64 NOT NULL,
  title STRING,
  firstname STRING,
  middleinitial STRING,
  lastname STRING,
  suffix STRING,
  addresstype STRING NOT NULL,
  addressline1 STRING NOT NULL,
  addressline2 STRING,
  city STRING NOT NULL,
  state STRING NOT NULL,
  county STRING NOT NULL,
  country STRING NOT NULL,
  zipcode STRING NOT NULL,
  plus4 STRING,
  addressupdateddate DATETIME,
  mobilephonenumber STRING,
  homephonenumber STRING,
  workphonenumber STRING,
  preferredphonetype STRING,
  customerplanid INT64 NOT NULL,
  customerplandesc STRING,
  accountcategoryid INT64,
  accountcategorydesc STRING,
  accounttypeid INT64 NOT NULL,
  accounttypecode STRING NOT NULL,
  accounttypedesc STRING NOT NULL,
  accountstatusid INT64 NOT NULL,
  accountstatuscode STRING NOT NULL,
  accountstatusdesc STRING NOT NULL,
  accountstatusdate DATE NOT NULL,
  customerstatusid INT64 NOT NULL,
  customerstatuscode STRING NOT NULL,
  customerstatusdesc STRING NOT NULL,
  revenuecategoryid INT64 NOT NULL,
  revenuecategorycode STRING NOT NULL,
  revenuecategorydesc STRING NOT NULL,
  revenuetypeid INT64 NOT NULL,
  revenuetypecode STRING,
  revenuetypedesc STRING,
  channelid INT64 NOT NULL,
  channelname STRING NOT NULL,
  channeldesc STRING NOT NULL,
  rebillamount NUMERIC(31, 2) NOT NULL,
  rebilldate DATETIME,
  autoreplenishmentid INT64 NOT NULL,
  autoreplenishmentcode STRING NOT NULL,
  autoreplenishmentdesc STRING NOT NULL,
  tolltagacctbalance NUMERIC(31, 2),
  zipcashcustbalance NUMERIC(31, 2),
  refundbalance NUMERIC(31, 2),
  tolltagdepositbalance NUMERIC(31, 2),
  fleetacctbalance NUMERIC(31, 2),
  companycode STRING,
  companyname STRING,
  fleetflag INT64 NOT NULL,
  badaddressflag INT64 NOT NULL,
  incollectionsflag INT64 NOT NULL,
  hvflag INT64 NOT NULL,
  adminhearingscheduledflag INT64 NOT NULL,
  paymentplanestablishedflag INT64 NOT NULL,
  vrbflag INT64 NOT NULL,
  citationissuedflag INT64 NOT NULL,
  bankruptcyflag INT64 NOT NULL,
  writeoffflag INT64 NOT NULL,
  groundtransportationflag INT64 NOT NULL,
  autorecalcreplamtflag INT64 NOT NULL,
  autorebillfailedflag INT64 NOT NULL,
  autorebillfailed_startdate DATETIME,
  expiredcreditcardflag INT64 NOT NULL,
  expiredcreditcard_startdate DATETIME,
  tolltagacctnegbalanceflag INT64 NOT NULL,
  tolltagacctlowbalanceflag INT64 NOT NULL,
  thresholdamount NUMERIC(31, 2),
  lowbalancedate DATETIME,
  negbalancedate DATETIME,
  linktolltagcustomerid INT64,
  zipcashtotolltagflag INT64,
  zipcashtotolltagdate DATETIME,
  tolltagtozipcashflag INT64,
  tolltagtozipcashdate DATETIME,
  directacctflag INT64 NOT NULL,
  seq1 INT64,
  seq2 INT64,
  zc_tolltagacctcreatedate DATETIME,
  zipcashacctcount INT64,
  firstzipcashcustomerid INT64,
  firstzipcashacctcreatedate DATETIME,
  lastzipcashcustomerid INT64,
  lastzipcashacctcreatedate DATETIME,
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
  accountlastcloseposid INT64,
  updateddate DATETIME,
  lnd_updatedate DATETIME,
  edw_updatedate DATETIME
)
CLUSTER BY customerid
;