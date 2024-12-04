CREATE OR REPLACE PROCEDURE `EDW_SHARED_DATA.Credit_Card_Monitoring_Load`()
BEGIN

/*
#####################################################################################################################################
Proc Description: Merges Credit card monitoring data from Stage table to Main table 
-------------------------------------------------------------------------------------------------------------------------------------
The primary objective of Credit Card Monitoring project is to automate credit card transaction monitoring. This includes the following tasks:
1.	Daily Exception Reports: Generate reports highlighting any exceptions or anomalies in credit card transactions.
2.	Weekly Reconciliation: Perform weekly reconciliation of credit card transactions to ensure accuracy.
3.	Chargeback Data Integration: Integrate chargeback data retrieval and reconciliation processes.
-------------------------------------------------------------------------------------------------------------------------------------
Parameters : 
====================================================================================================================================
Change Log:
-------------------------------------------------------------------------------------------------------------------------------------
PRJ0073949  Venkat/Dhanush 2024-09-13  NEW!




#####################################################################################################################################
*/
      


DECLARE log_source STRING DEFAULT 'Credit_Card_Monitoring_Load';
DECLARE log_start_date DATETIME; 
DECLARE log_message STRING; 
DECLARE trace_flag INT64 DEFAULT 0;
BEGIN 
DECLARE ROW_COUNT INT64;
SET log_start_date = current_datetime('America/Chicago'); 
CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, 'Started_Credit_Card_Monitoring_Load', 'I', CAST(NULL AS INT64), CAST(NULL AS STRING));

--Load Table ACT0002 from Stage to LND		
create TEMP TABLE temp_002 as 
	Select  recordtype,
			PARSE_DATE('%m/%d/%Y',submissiondate) as submissiondate,
			Cast(pidno AS INT64) as pidno,
			pidshortname,
			submissionno,
			Cast(recordno as INT64) as recordno,
			entitytype,
			Cast(entityno as INT64) as entityno,
			presentmentcurrency,
			replace(merchantorderno,'"','') as merchantorderno,
			rdfino,
			accountno,
			expirationdate,
			Cast(amount as NUMERIC) as amount,
			mop,
			actioncode,
			Cast(authdate as STRING) as authdate,
			authcode,
			authresponsecode,
			traceno,
			consumercountrycode,
			category,
			Cast(mcc as INT64) as mcc,
			Cast(rejectcode as INT64) as rejectcode,
			submissionstatus
	FROM `LND_SHARED_DATA.Stage_Exception_Detail_ACT0002` ;

	

	MERGE `LND_SHARED_DATA.Exception_Detail_ACT0002` AS m
	USING temp_002 AS s
	ON m.merchantorderno = s.merchantorderno
	WHEN NOT MATCHED BY TARGET
	THEN INSERT (recordtype,
					submissiondate,
					pidno,
					pidshortname,
					submissionno,
					recordno,
					entitytype,
					entityno,
					presentmentcurrency,
					merchantorderno,
					rdfino,
					accountno,
					expirationdate,
					amount,
					mop,
					actioncode,
					authdate,
					authcode,
					authresponsecode,
					traceno,
					consumercountrycode,
					category,
					mcc,
					rejectcode,
					submissionstatus,
                    lnd_updatedate)
	VALUES (s.recordtype,
					s.submissiondate,
					s.pidno,
					s.pidshortname,
					s.submissionno,
					s.recordno,
					s.entitytype,
					s.entityno,
					s.presentmentcurrency,
					s.merchantorderno,
					s.rdfino,
					s.accountno,
					s.expirationdate,
					s.amount,
					s.mop,
					s.actioncode,
					s.authdate,
					s.authcode,
					s.authresponsecode,
					s.traceno,
					s.consumercountrycode,
					s.category,
					s.mcc,
					s.rejectcode,
					s.submissionstatus,
                    CURRENT_DATETIME());
					
SET log_message = 'Loaded Exception_Detail_ACT0002'; 
CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, log_message, 'I', -1, CAST(NULL AS STRING));

--Load Table ACT0010 from Stage to LND
create TEMP TABLE temp_010 as 
Select recordtype,
    PARSE_DATE('%m/%d/%Y',submissiondate) as submissiondate,
    Cast(pidno as INT64) as pidno,
    pidshortname,
    submissionno,
    Cast(recordno as INT64) as recordno,
    entitytype,
    Cast(entityno as INT64) as entityno,
    presentmentcurrency,
    replace(merchantorderno,'"','') as merchantorderno,
    rdfino,
    accountno,
    expirationdate,
    Cast(amount as NUMERIC) as amount,
    mop,
    actioncode,
    Case When authdate="" THEN "2099-12-12" ELSE PARSE_DATE('%m/%d/%Y',authdate) END as authdate,
    authcode,
    Case when authresponsecode="" THEN 00 ELSE Cast(authresponsecode as INT64) END as authresponsecode,
    traceno,
    consumercountrycode,
    reserved,
    Cast(mcc as INT64) as mcc,
    string_field_23,
    string_field_24,
    string_field_25,
    string_field_26,
    string_field_27,
    string_field_28,
    Case when bool_field_29="F" THEN Cast(false as BOOL) ELSE Cast(true as BOOL) END as bool_field_29,
    Cast(double_field_30 as NUMERIC) as double_field_30,
    Cast(double_field_31 as NUMERIC) as double_field_31,
    Cast(double_field_32 as NUMERIC) as double_field_32,
    Cast(double_field_33 as NUMERIC) as double_field_33,
    string_field_34,
    string_field_35
 FROM `LND_SHARED_DATA.Stage_Deposit_Detail_ACT0010` ;



MERGE `LND_SHARED_DATA.Deposit_Detail_ACT0010` AS m
USING temp_010 AS s
ON m.merchantorderno = s.merchantorderno
WHEN NOT MATCHED BY TARGET
THEN INSERT (recordtype,
    submissiondate,
    pidno,
    pidshortname,
    submissionno,
    recordno,
    entitytype,
    entityno,
    presentmentcurrency,
    merchantorderno,
    rdfino,
    accountno,
    expirationdate,
    amount,
    mop,
    actioncode,
    authdate,
    authcode,
    authresponsecode,
    traceno,
    consumercountrycode,
    reserved,
    mcc,
    string_field_23,
    string_field_24,
    string_field_25,
    string_field_26,
    string_field_27,
    string_field_28,
    bool_field_29,
    double_field_30,
    double_field_31,
    double_field_32,
    double_field_33,
    string_field_34,
    string_field_35,
    lnd_updatedate)
VALUES (s.recordtype,
    s.submissiondate,
    s.pidno,
    s.pidshortname,
   s.submissionno,
    s.recordno,
    s.entitytype,
    s.entityno,
    s.presentmentcurrency,
    s.merchantorderno,
    s.rdfino,
    s.accountno,
    s.expirationdate,
    s.amount,
    s.mop,
    s.actioncode,
    s.authdate,
    s.authcode,
   s.authresponsecode,
    s.traceno,
    s.consumercountrycode,
    s.reserved,
    s.mcc,
    s.string_field_23,
    s.string_field_24,
    s.string_field_25,
    s.string_field_26,
    s.string_field_27,
   s.string_field_28,
    s.bool_field_29,
   s.double_field_30,
   s.double_field_31,
    s.double_field_32,
    s.double_field_33,
    s.string_field_34,
    s.string_field_35,
    CURRENT_DATETIME());	
	
SET log_message = 'Loaded Deposit_Detail_ACT0010'; 
CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, log_message, 'I', -1, CAST(NULL AS STRING));	



EXCEPTION WHEN ERROR THEN BEGIN DECLARE error_message STRING DEFAULT @@error.message;

     CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, error_message, 'E', CAST(NULL AS INT64), CAST(NULL AS STRING));
     RAISE USING MESSAGE = error_message; -- ReThrow the error !


END;
END;
END;