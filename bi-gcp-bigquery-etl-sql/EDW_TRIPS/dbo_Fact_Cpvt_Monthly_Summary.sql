create table IF NOT EXISTS `EDW_TRIPS.Fact_Cpvt_Monthly_Summary` (
monthid INTEGER ,
commitments NUMERIC(31, 2) ,
tolls NUMERIC(31, 2) ,
vtolls NUMERIC(31, 2) ,
tollpayment NUMERIC(31, 2) ,
tollreversalpayment NUMERIC(31, 2) ,
tollvoidpayment NUMERIC(31, 2) ,
feepayment NUMERIC(31, 2) ,
feereversalpayment NUMERIC(31, 2) ,
feevoidpayment NUMERIC(31, 2) ,
edw_updatedate DATETIME,
primary key (monthid) NOT ENFORCED)
CLUSTER BY monthid
;
