CREATE OR REPLACE PROCEDURE `EDW_TRIPS.Dim_Customer_Full_Load`()
BEGIN 
DECLARE log_source STRING DEFAULT 'EDW_TRIPS.Dim_Customer_Full_Load'; 
DECLARE log_start_date DATETIME; 
DECLARE log_message STRING;
  
BEGIN 
DECLARE ROW_COUNT INT64;
DECLARE trace_flag INT64 DEFAULT 0;
/*
###################################################################################################################
Proc Description: 
-------------------------------------------------------------------------------------------------------------------
Load dbo.Dim_Customer table. 
===================================================================================================================
Change Log:
-------------------------------------------------------------------------------------------------------------------
CHG0037838	Andy and Shankar		2020-10-19	New!
			
CHG0040056	Shankar					2021-10-05	BadAddressFlag = 0 for Prepaid customer not in delinquent status
			 						2021-08-04	Get current Customer Flag values, not expired values
									2021-11-24	Get Account Status Dates and related attributes
									2021-11-24	Add AutoReplenishmentID (Cash/CC rebill type) and AutoRecalcReplAmt
												Flag. This flag sets the rebill amount to the average of your last 
												three months usage and is effective only if the average is greater 
												than the minimum Replenishment Amount.
									2022-12-16  Tag Store Reporting Requirements.
												Item 49 Reports.
CHG0042384	Shankar					2022-12-20  1. TollTagAcctLowBalanceFlag, TollTagAcctNegBalanceFlag
												2. DirectAcctFlag, ZipCashToTollTagFlag and TollTagToZipCashFlag
CHG0043732	Shankar					2023-03-03  1. Typo fix. Rename InCollVRBectionsFlag as VRBFlag
												2. Add AutoRebillFailedFlag, ExpiredCreditCardFlag with
												   respective most recent Start Date
												3. Load customer address info even if it bad address
												4. Add Customer phone numbers	
												
CHG0044084	Shankar					2023-11-27	Fix ExpiredCreditCardFlag and AutoRebillFailedFlag values in Dim_Customer

CHG0044450	Shankar					2023-02-05	Added County from TollPlus.ZipCodes
DFCT0013414 Dhanush         2024-10-08  Changed the path location from Tollplus.zipcodes to EDW_TRIPS. 
                            Dim_zipcodes, which contains the latest zipcode data provided by the GIS team.
===================================================================================================================
Example:
-------------------------------------------------------------------------------------------------------------------
EXEC dbo.Dim_Customer_Full_Load
SELECT * FROM Utility.ProcessLog WHERE LogSource LIKE '%Dim_Customer%' ORDER BY 1 DESC 
SELECT TOP 100 'dbo.Dim_Customer' Table_Name, * FROM dbo.Dim_Customer ORDER BY 2
SELECT * FROM Utility.ProcessLog WHERE LogSource LIKE '%Dim_AccountStatusTracker%' ORDER BY 1 DESC 
SELECT TOP 100 'dbo.Dim_AccountStatusTracker' Table_Name, * FROM dbo.Dim_AccountStatusTracker ORDER BY 2 DESC, 3
SELECT TOP 1000 'Stage.AccountStatusDetail' TableName, * FROM Stage.AccountStatusDetail ORDER BY 2 DESC
###################################################################################################################
*/

SET log_start_date = current_datetime('America/Chicago'); 

CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, 'Started full load', 'I', NULL, NULL);


-- DROP TABLE IF EXISTS _SESSION.Customer_Balances;

-- :: Get Customer Balances

CREATE OR REPLACE
TEMPORARY TABLE _SESSION.Customer_Balances CLUSTER BY CustomerID AS
SELECT
  customerid,
  MAX(IF(balancetype = 'TollBal', balanceamount, NULL)) AS tolltagacctbalance,
  MAX(IF(balancetype = 'VioBal', balanceamount, NULL)) AS zipcashcustbalance,
  MAX(IF(balancetype = 'RefundBal', balanceamount, NULL)) AS refundbalance,
  MAX(IF(balancetype = 'TagDepBal', balanceamount, NULL)) AS tolltagdepositbalance,
  MAX(IF(balancetype = 'PostBal', balanceamount, NULL)) AS fleetacctbalance
FROM
  LND_TBOS.TollPlus_TP_Customer_Balances
WHERE
  balancetype IN ('TollBal', 'VioBal', 'RefundBal', 'TagDepBal', 'PostBal')
  AND lnd_updatetype <> 'D'
GROUP BY
  customerid;

SET log_message = 'Loaded #Customer_Balances'; 
CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, log_message, 'I', -1, NULL);


-- :: Get Customer Phone numbers

--DROP TABLE IF EXISTS _SESSION.CustomerPhones;
CREATE 
TEMPORARY TABLE _SESSION.cte_customerid  AS
  (SELECT DISTINCT TollPlus_TP_Customer_Phones.customerid
   FROM LND_TBOS.TollPlus_TP_Customer_Phones
   WHERE TollPlus_TP_Customer_Phones.isactive = 1
     AND TollPlus_TP_Customer_Phones.lnd_updatetype <> 'D' );
CREATE
TEMPORARY TABLE _SESSION.cte_mobilephone AS
  (SELECT TollPlus_TP_Customer_Phones.customerid,
          TollPlus_TP_Customer_Phones.phonetype,
          TollPlus_TP_Customer_Phones.phonenumber AS mobilephonenumber,
          TollPlus_TP_Customer_Phones.iscommunication,
          TollPlus_TP_Customer_Phones.isbadphone,
          row_number() OVER (PARTITION BY TollPlus_TP_Customer_Phones.customerid,
                                          TollPlus_TP_Customer_Phones.phonetype,
                                          TollPlus_TP_Customer_Phones.phonenumber
                             ORDER BY TollPlus_TP_Customer_Phones.iscommunication DESC) AS rn_mobilenumber
   FROM LND_TBOS.TollPlus_TP_Customer_Phones
   WHERE TollPlus_TP_Customer_Phones.isactive = 1
     AND TollPlus_TP_Customer_Phones.phonetype = 'MobileNo'
     AND TollPlus_TP_Customer_Phones.lnd_updatetype <> 'D' );
CREATE
TEMPORARY TABLE _SESSION.cte_homephone AS
  (SELECT TollPlus_TP_Customer_Phones.customerid,
          TollPlus_TP_Customer_Phones.phonetype,
          TollPlus_TP_Customer_Phones.phonenumber AS homephonenumber,
          TollPlus_TP_Customer_Phones.iscommunication,
          TollPlus_TP_Customer_Phones.isbadphone,
          row_number() OVER (PARTITION BY TollPlus_TP_Customer_Phones.customerid,
                                          TollPlus_TP_Customer_Phones.phonetype,
                                          TollPlus_TP_Customer_Phones.phonenumber
                             ORDER BY TollPlus_TP_Customer_Phones.iscommunication DESC) AS rn_homenumber
   FROM LND_TBOS.TollPlus_TP_Customer_Phones
   WHERE TollPlus_TP_Customer_Phones.isactive = 1
     AND TollPlus_TP_Customer_Phones.phonetype = 'HomePhone'
     AND TollPlus_TP_Customer_Phones.lnd_updatetype <> 'D' );
CREATE
TEMPORARY TABLE _SESSION.cte_workphone AS
  (SELECT TollPlus_TP_Customer_Phones.customerid,
          TollPlus_TP_Customer_Phones.phonetype,
          TollPlus_TP_Customer_Phones.phonenumber AS workphonenumber,
          TollPlus_TP_Customer_Phones.iscommunication,
          TollPlus_TP_Customer_Phones.isbadphone,
          row_number() OVER (PARTITION BY TollPlus_TP_Customer_Phones.customerid,
                                          TollPlus_TP_Customer_Phones.phonetype,
                                          TollPlus_TP_Customer_Phones.phonenumber
                             ORDER BY TollPlus_TP_Customer_Phones.iscommunication DESC) AS rn_worknumber
   FROM LND_TBOS.TollPlus_TP_Customer_Phones
   WHERE TollPlus_TP_Customer_Phones.isactive = 1
     AND TollPlus_TP_Customer_Phones.phonetype = 'WorkPhone'
     AND TollPlus_TP_Customer_Phones.lnd_updatetype <> 'D' );
CREATE  OR REPLACE TEMPORARY TABLE _SESSION.CustomerPhones CLUSTER BY CustomerID AS
SELECT c.customerid,
       mp.mobilephonenumber,
       hp.homephonenumber,
       wp.workphonenumber,
       SUBSTR(CAST(CASE 1
                       WHEN mp.iscommunication THEN 'MobilePhone'
                       WHEN hp.iscommunication THEN 'HomePhone'
                       WHEN wp.iscommunication THEN 'WorkPhone'
                   END AS STRING) , 1, 15) AS PreferredPhoneType
FROM cte_customerid AS c
LEFT OUTER JOIN cte_mobilephone AS  mp ON c.customerid = mp.customerid
AND mp.rn_mobilenumber = 1
LEFT OUTER JOIN cte_homephone AS hp ON c.customerid = hp.customerid
AND hp.rn_homenumber = 1
LEFT OUTER JOIN cte_workphone AS wp ON c.customerid = wp.customerid
AND wp.rn_worknumber = 1 ;
SET log_message = 'Loaded #CustomerPhones'; 
CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, log_message, 'I', -1, NULL);

-- :: Get Customer Flags

--DROP TABLE IF EXISTS _SESSION.CustomerFlags;
CREATE OR REPLACE
TEMPORARY TABLE _SESSION.CustomerFlags CLUSTER BY CustomerID AS
SELECT
  c.customerid,
  MAX(IF(c.flagname = 'IsBadAddress', c.flagvalue, NULL)) AS isbadaddress,
  MAX(IF(c.flagname = 'IsInCollections', c.flagvalue, NULL)) AS isincollections,
  MAX(IF(c.flagname = 'IsHV', c.flagvalue, NULL)) AS ishv,
  MAX(IF(c.flagname = 'IsAdminHearingScheduled', c.flagvalue, NULL)) AS isadminhearingscheduled,
  MAX(IF(c.flagname = 'IsPaymentPlanEstablished', c.flagvalue, NULL)) AS ispaymentplanestablished,
  MAX(IF(c.flagname = 'IsVRB', c.flagvalue, NULL)) AS isvrb,
  MAX(IF(c.flagname = 'IsCitationIssued', c.flagvalue, NULL)) AS iscitationissued,
  MAX(IF(c.flagname = 'IsBankruptcy', c.flagvalue, NULL)) AS isbankruptcy,
  MAX(IF(c.flagname = 'IsWriteOff', c.flagvalue, NULL)) AS iswriteoff
FROM
  (
    SELECT 
      f.customerid,
      l.flagname,
      CAST(f.flagvalue AS INT64) AS flagvalue
    FROM 
      LND_TBOS.TollPlus_TP_Customer_Flags AS f
    INNER JOIN 
      LND_TBOS.TollPlus_CustomerFlagReferenceLookup AS l ON l.customerflagreferenceid = f.customerflagreferenceid
    WHERE 
      l.flagname IN ('IsBadAddress', 'IsInCollections', 'IsHV', 'IsAdminHearingScheduled', 'IsPaymentPlanEstablished', 'IsVRB', 'IsCitationIssued', 'IsBankruptcy', 'IsWriteOff')
      AND f.enddate > CURRENT_DATETIME()
      AND f.lnd_updatetype <> 'D'
  ) AS c
GROUP BY
  c.customerid;

SET log_message = 'Loaded #CustomerFlags'; 
CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, log_message, 'I', -1, NULL);
-- SELECT log_source,log_start_date,log_message, 'I', -1, NULL;
CREATE
TEMPORARY TABLE _SESSION.cte_flagdatestoday AS
  (SELECT f.customerid,
          l.customerflagreferenceid,
          l.flagname,
          f.flagvalue,
          f.startdate,
          f.enddate,
          row_number() OVER (PARTITION BY f.customerid,
                                          l.flagname
                             ORDER BY f.startdate DESC, f.enddate DESC) AS rn
   FROM LND_TBOS.TollPlus_TP_Customer_Flags AS f
   INNER JOIN LND_TBOS.TollPlus_CustomerFlagReferenceLookup AS l ON l.customerflagreferenceid = f.customerflagreferenceid
   WHERE l.flagname IN('IsTollReplenishmentFailed',
                       'IsInvalidTollCard')
     AND f.enddate > current_datetime()
     AND f.lnd_updatetype <> 'D' );
CREATE
TEMPORARY TABLE _SESSION.cte_customerids AS
  (SELECT DISTINCT cte_flagdatestoday.customerid
   FROM cte_flagdatestoday);

-- :: Get Customer Flags Start Date

--DROP TABLE IF EXISTS _SESSION.CustomerFlagDates;
CREATE OR REPLACE TEMPORARY TABLE _SESSION.CustomerFlagDates CLUSTER by CustomerID AS
SELECT c.customerid,
       CAST( fd1.flagvalue AS INT64) AS autorebillfailedflag,
       fd1.startdate AS autorebillfailed_startdate,
       fd1.enddate AS autorebillfailed_enddate,
       CAST( fd2.flagvalue AS INT64) AS expiredcreditcardflag,
       fd2.startdate AS expiredcreditcard_startdate,
       fd2.enddate AS expiredcreditcard_enddate
FROM cte_customerids AS c
LEFT OUTER JOIN cte_flagdatestoday AS fd1 ON c.customerid = fd1.customerid
AND fd1.flagname = 'IsTollReplenishmentFailed'
AND fd1.rn = 1
LEFT OUTER JOIN cte_flagdatestoday AS fd2 ON c.customerid = fd2.customerid
AND fd2.flagname = 'IsInvalidTollCard'
AND fd2.rn = 1 ;
SET log_message = 'Loaded #CustomerFlagDates'; 
CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, log_message, 'I', -1, NULL);


--DROP TABLE IF EXISTS _SESSION.Customer_UpdatedDates ;
CREATE OR REPLACE
TEMPORARY TABLE _SESSION.cte_customer_updateddates AS
  (SELECT 'TP_Customers' AS tablename,
          TollPlus_TP_Customers.customerid,
          max(TollPlus_TP_Customers.updateddate) AS lastupdateddate
   FROM LND_TBOS.TollPlus_TP_Customers
   WHERE TollPlus_TP_Customers.lnd_updatetype <> 'D'
   GROUP BY CustomerID
   UNION DISTINCT SELECT 'TP_Customer_Attributes' AS tablename,
                         TollPlus_TP_Customer_Attributes.customerid,
                         max(TollPlus_TP_Customer_Attributes.updateddate) AS lastupdateddate
   FROM LND_TBOS.TollPlus_TP_Customer_Attributes
   WHERE TollPlus_TP_Customer_Attributes.lnd_updatetype <> 'D'
   GROUP BY CustomerID
   UNION DISTINCT SELECT 'TollPlus_TP_Customer_Contacts' AS tablename,
                         TollPlus_TP_Customer_Contacts.customerid,
                         max(TollPlus_TP_Customer_Contacts.updateddate) AS lastupdateddate
   FROM LND_TBOS.TollPlus_TP_Customer_Contacts
   WHERE TollPlus_TP_Customer_Contacts.lnd_updatetype <> 'D'
   GROUP BY CustomerID
   UNION DISTINCT SELECT 'TP_Customer_Addresses' AS tablename,
                         TollPlus_TP_Customer_Addresses.customerid,
                         max(TollPlus_TP_Customer_Addresses.updateddate) AS lastupdateddate
   FROM LND_TBOS.TollPlus_TP_Customer_Addresses
   WHERE TollPlus_TP_Customer_Addresses.lnd_updatetype <> 'D'
   GROUP BY CustomerID
   UNION DISTINCT SELECT 'TP_Customer_Plans' AS tablename,
                         TollPlus_TP_Customer_Plans.customerid,
                         max(TollPlus_TP_Customer_Plans.updateddate) AS lastupdateddate
   FROM LND_TBOS.TollPlus_TP_Customer_Plans
   WHERE TollPlus_TP_Customer_Plans.lnd_updatetype <> 'D'
   GROUP BY CustomerID
   UNION DISTINCT SELECT 'TP_Customer_Flags' AS tablename,
                         TollPlus_TP_Customer_Flags.customerid,
                         max(TollPlus_TP_Customer_Flags.updateddate) AS lastupdateddate
   FROM LND_TBOS.TollPlus_TP_Customer_Flags
   WHERE TollPlus_TP_Customer_Flags.lnd_updatetype <> 'D'
   GROUP BY CustomerID);
CREATE TEMPORARY TABLE _SESSION.Customer_UpdatedDates CLUSTER BY CustomerID AS
SELECT cte_customer_updateddates.customerid,
       max(cte_customer_updateddates.lastupdateddate) AS updateddate -- Last UpdatedDate from anyone of these tables for Customer ID
FROM cte_customer_updateddates
GROUP BY CustomerID ;




SET log_message = 'Loaded #Customer_UpdatedDates'; 
CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, log_message, 'I', -1, NULL); 

-- :: Load dbo.Dim_AccountStatusTracker

CALL EDW_TRIPS.Dim_AccountStatusTracker_Full_Load();
SET log_message = 'Executed dbo.Dim_AccountStatusTracker_Full_Load'; 
CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, log_message, 'I', -1, NULL);

-- :: Get ZC Customer Transition cases. From ZipCash accounts viewpoint. NOTE: (1 to 1) -->> 1 Zipcash account = 1 LP. LinkTollTagCustomerID is only one way and is present only on ZC Customer rec, not on TollTag Customer rec.

--DROP TABLE IF EXISTS _SESSION.ZC_CustTransition ;
CREATE OR REPLACE
TEMPORARY TABLE _SESSION.ZC_CustTransition CLUSTER BY ZipCashCustomerID AS
SELECT zc.regcustrefid AS linktolltagcustomerid,
       tt.accountcreatedate AS tolltagacctcreatedate,
       zc.customerid AS zipcashcustomerid,
       zc.accountcreatedate AS zipcashacctcreatedate,
       CAST(row_number() OVER (PARTITION BY zc.regcustrefid
                               ORDER BY zc.accountcreatedate) AS INT64) AS seq1,
       CAST(row_number() OVER (PARTITION BY zc.regcustrefid
                               ORDER BY zc.accountcreatedate DESC) AS INT64) AS seq2,
       CAST(CASE
                WHEN tt.accountcreatedate > zc.accountcreatedate THEN 1
                ELSE 0
            END AS INT64) AS zipcashtotolltagflag,
       CASE
           WHEN tt.accountcreatedate > zc.accountcreatedate THEN tt.accountcreatedate
       END AS zipcashtotolltagdate,
       CAST(CASE
                WHEN tt.accountcreatedate < zc.accountcreatedate THEN 1
                ELSE 0
            END AS INT64) AS tolltagtozipcashflag,
       CASE
           WHEN tt.accountcreatedate < zc.accountcreatedate THEN zc.accountcreatedate
       END AS tolltagtozipcashdate
FROM EDW_TRIPS_STAGE.AccountStatusDetail AS zc
INNER JOIN EDW_TRIPS_STAGE.AccountStatusDetail AS tt ON tt.customerid = zc.regcustrefid
WHERE zc.usertypeid = 11
  AND zc.regcustrefid > 0
  AND tt.accountopendate IS NOT NULL ;
  SET log_message = 'Loaded #ZC_CustTransition'; 
  CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, log_message, 'I', -1, NULL);


  -- :: Get TT Customer Transition cases. From Tolltag accounts viewpoint. NOTE: (1 to many) -->> 1 TollTag account = 1 or more Tag/LP.  

  --DROP TABLE IF EXISTS _SESSION.TT_CustTransition;
  CREATE OR REPLACE
  TEMPORARY TABLE _SESSION.TT_CustTransition CLUSTER BY LinkTollTagCustomerID AS
  SELECT zc_first.linktolltagcustomerid,
         tt.accountcreatedate AS tolltagacctcreatedate,
         zc_first.zipcashcustomerid AS firstzipcashcustomerid,
         zc_first.zipcashacctcreatedate AS firstzipcashacctcreatedate,
         zc_last.zipcashcustomerid AS lastzipcashcustomerid,
         zc_last.zipcashacctcreatedate AS lastzipcashacctcreatedate,
         zc_first.zipcashacctcount,
         CAST(CASE
                  WHEN tt.accountcreatedate > zc_first.zipcashacctcreatedate THEN 1
                  ELSE 0
              END AS INT64) AS zipcashtotolltagflag,
         CASE
             WHEN tt.accountcreatedate > zc_first.zipcashacctcreatedate THEN tt.accountcreatedate
         END AS zipcashtotolltagdate,
         CAST(CASE
                  WHEN tt.accountcreatedate < zc_last.zipcashacctcreatedate THEN 1
                  ELSE 0
              END AS INT64) AS tolltagtozipcashflag,
         tt_zc.tolltagtozipcashdate
  FROM
    (SELECT t.linktolltagcustomerid,
            t.zipcashcustomerid AS zipcashcustomerid,
            t.zipcashacctcreatedate AS zipcashacctcreatedate,
            t.seq2 AS zipcashacctcount
     FROM _SESSION.ZC_CustTransition AS t
     WHERE t.seq1 = 1 ) AS zc_first
  INNER JOIN
    (SELECT t.linktolltagcustomerid,
            t.zipcashcustomerid AS zipcashcustomerid,
            t.zipcashacctcreatedate AS zipcashacctcreatedate
     FROM _SESSION.ZC_CustTransition AS t
     WHERE t.seq2 = 1 ) AS zc_last ON zc_first.linktolltagcustomerid = zc_last.linktolltagcustomerid
  INNER JOIN
    (SELECT ZC_CustTransition.linktolltagcustomerid,
            min(ZC_CustTransition.tolltagtozipcashdate) AS tolltagtozipcashdate
     FROM _SESSION.ZC_CustTransition AS ZC_CustTransition
     GROUP BY linktolltagcustomerid) AS tt_zc ON tt_zc.linktolltagcustomerid = zc_first.linktolltagcustomerid
  INNER JOIN EDW_TRIPS_STAGE.accountstatusdetail AS tt ON tt.customerid = zc_first.linktolltagcustomerid ;
  
      /*
  		SELECT LinkTollTagCustomerID,TollTagAcctCreateDate, ZipCashCustomerID AS CustomerID, ZipCashAcctCreateDate AS AccountCreateDate, 'ZipCash' CustomerCategroy, Seq1, Seq2, ZipCashToTollTagFlag, ZipCashToTollTagDate, TollTagToZipCashFlag, TollTagToZipCashDate
		FROM dbo.#ZC_CustTransition 
		WHERE LinkTollTagCustomerID = 2011697589  
		UNION
		SELECT LinkTollTagCustomerID,TollTagAcctCreateDate, LinkTollTagCustomerID AS CustomerID, TollTagAcctCreateDate AS AccountCreateDate, 'TagStore' CustomerCategroy, 0 Seq1, 0 Seq2, ZipCashToTollTagFlag, ZipCashToTollTagDate, TollTagToZipCashFlag, TollTagToZipCashDate
		FROM #TT_CustTransition
		WHERE LinkTollTagCustomerID = 2011697589  
		ORDER BY 1, AccountCreateDate		
		*/


  
  SET log_message = 'Loaded #TT_CustTransition'; 
  CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, log_message, 'I', -1, NULL);
  
  --=============================================================================================================
	-- Load dbo.Dim_Customer
	--=============================================================================================================


  --DROP TABLE IF EXISTS EDW_TRIPS.Dim_Customer;
  CREATE OR REPLACE TABLE EDW_TRIPS.Dim_Customer CLUSTER BY CustomerID AS
  SELECT coalesce(CAST( TollPlus_tp_customers.customerid AS INT64), -1) AS customerid,
         
         -- :: Customer Profile
         CAST( TollPlus_tp_customer_contacts.title AS STRING) AS title,
         CAST( TollPlus_tp_customer_contacts.firstname AS STRING) AS firstname,
         CAST( TollPlus_tp_customer_contacts.middlename AS STRING) AS middleinitial,
         CAST( TollPlus_tp_customer_contacts.lastname AS STRING) AS lastname,
         CAST( TollPlus_tp_customer_contacts.suffix AS STRING) AS suffix,
         coalesce(CAST( TollPlus_tp_customer_addresses.addresstype AS STRING), '') AS addresstype,
         coalesce(CAST( TollPlus_tp_customer_addresses.addressline1 AS STRING), '') AS addressline1,
         CAST( TollPlus_tp_customer_addresses.addressline2 AS STRING) AS addressline2,
         coalesce(CAST( zipcodes.city AS STRING), '') AS city,
         coalesce(CAST( zipcodes.state AS STRING), '') AS state,
         coalesce(CAST( zipcodes.county AS STRING), 'UNK') AS county,
         coalesce(CAST( TollPlus_tp_customer_addresses.country AS STRING), '') AS country,
         coalesce(CAST( TollPlus_tp_customer_addresses.zip1 AS STRING), '') AS zipcode,
         CAST( TollPlus_tp_customer_addresses.zip2 AS STRING) AS plus4,
         CAST( TollPlus_tp_customer_addresses.addressupdateddate AS DATETIME) AS addressupdateddate,
         
         -- :: Customer Phone info
         CAST( CustomerPhones.mobilephonenumber AS STRING) AS mobilephonenumber,
         CAST( CustomerPhones.homephonenumber AS STRING) AS homephonenumber,
         CAST( CustomerPhones.workphonenumber AS STRING) AS workphonenumber,
         CAST(CustomerPhones.preferredphonetype AS string) AS preferredphonetype,
         
         
         -- :: Customer Plan dimension 
         coalesce(CAST( TollPlus_Plans.planid AS INT64), -1) AS customerplanid,
         CAST(coalesce(replace(replace(TollPlus_Plans.planname, 'Postpaid', 'Postpaid'), 'Prepaid', 'Prepaid'), 'N/A') AS STRING) AS customerplandesc,
         
         
         -- :: AccountCategory dimension
         CASE
             WHEN TollPlus_tp_customers.usertypeid IN(2,
                                             3)
                  AND TollPlus_Plans.planname = 'Prepaid' THEN 1
             WHEN TollPlus_tp_customers.usertypeid IN(2,
                                             3)
                  AND TollPlus_Plans.planname = 'Postpaid' THEN 3
             WHEN TollPlus_tp_customers.usertypeid = 11 THEN 2
         END AS accountcategoryid,
         CASE
             WHEN TollPlus_tp_customers.usertypeid IN(2,
                                             3)
                  AND TollPlus_Plans.planname = 'Prepaid' THEN 'TagStore'
             WHEN TollPlus_tp_customers.usertypeid IN(2,
                                             3)
                  AND TollPlus_Plans.planname = 'Postpaid' THEN 'Fleet'
             WHEN TollPlus_tp_customers.usertypeid = 11 THEN 'Zipcash'
         END AS accountcategorydesc,
         
         -- :: AccountType dimension
         coalesce(CAST( accounttype.accounttypeid AS INT64), -1) AS accounttypeid,
         coalesce(accounttype.accounttypecode, 'Unknown') AS accounttypecode,
         coalesce(accounttype.accounttypedesc, 'Unknown') AS accounttypedesc,
         
         -- :: AccountStatus dimension
         coalesce(CAST( accountstatus.accountstatusid AS INT64), -1) AS accountstatusid,
         coalesce(accountstatus.accountstatuscode, 'Unknown') AS accountstatuscode,
         coalesce(accountstatus.accountstatusdesc, 'Unknown') AS accountstatusdesc,
         coalesce(CAST( TollPlus_tp_customers.accountstatusdate AS DATE), DATE '1900-01-01') AS accountstatusdate,
         
         
         -- :: CustomerStatus dimension
         coalesce(customerstatus.customerstatusid, -1) AS customerstatusid,
         coalesce(customerstatus.customerstatuscode, 'Unknown') AS customerstatuscode,
         coalesce(customerstatus.customerstatusdesc, 'Unknown') AS customerstatusdesc,
         
         
         -- :: RevenueCategory dimension
         coalesce(CAST( TollPlus_tp_customers.revenuecategoryid AS INT64), 0) AS revenuecategoryid,
         coalesce(revenuecategory.revenuecategorycode, 'Unknown') AS revenuecategorycode,
         coalesce(revenuecategory.revenuecategorydesc, 'Unknown') AS revenuecategorydesc,
         
         
         -- :: RevenueType dimension
         coalesce(coalesce(revenuetype.revenuetypeid, TollPlus_tp_customers.revenuecategoryid), -1) AS revenuetypeid,
         CAST(coalesce(coalesce(revenuetype.revenuetypecode, revenuecategory.revenuecategorycode), 'Unknown') AS STRING) AS revenuetypecode,
         CAST(coalesce(coalesce(revenuetype.revenuetypedesc, revenuecategory.revenuecategorydesc), 'Unknown') AS STRING) AS revenuetypedesc,
         
         
         -- :: Channel dimension
         coalesce(channel.channelid, -1) AS channelid,
         coalesce(channel.channelname, 'Unknown') AS channelname,
         coalesce(channel.channeldesc, 'Unknown') AS channeldesc,
         
         
         -- :: Rebill Amount and various Balance type columns
         coalesce(calculatedrebillamount, 0) AS rebillamount,
         TollPlus_TP_Customer_Attributes.rebilldate AS rebilldate, -- !!COLUMN NOT USED IN TRIPS!!
         coalesce(autoreplenishment.autoreplenishmentid, -1) AS autoreplenishmentid,
         coalesce(autoreplenishment.autoreplenishmentcode, 'Unknown') AS autoreplenishmentcode,
         coalesce(autoreplenishment.autoreplenishmentdesc, 'Unknown') AS autoreplenishmentdesc,
         
         
         -- TP_Customer_Balances.BalanceDate AS BalanceDate
         Customer_Balances.tolltagacctbalance,
         Customer_Balances.zipcashcustbalance,
         Customer_Balances.refundbalance,
         Customer_Balances.tolltagdepositbalance,
         Customer_Balances.fleetacctbalance,
         
         -- :: Rental Car / Fleet company info
         CAST( TollPlus_tp_customer_attributes.companycode AS STRING) AS companycode,
         TollPlus_tp_customer_business.organisationname AS companyname,
         coalesce(TollPlus_tp_customer_business.isfleet, 0) AS fleetflag,
         
         
         -- :: CustomerFlags
         coalesce(CAST(CASE
                           WHEN TollPlus_Plans.planname = 'Prepaid'
                                AND CustomerFlags.isbadaddress = 1
                                AND accountstatus.accountstatusdesc <> 'Delinquent' THEN 0
                           ELSE CustomerFlags.isbadaddress
                       END AS INT64), 0) AS badaddressflag,
         coalesce(CAST(CustomerFlags.isincollections AS INT64), 0) AS incollectionsflag,
         coalesce(CAST(CustomerFlags.ishv AS INT64), 0) AS hvflag,
         coalesce(CAST(CustomerFlags.isadminhearingscheduled AS INT64), 0) AS adminhearingscheduledflag,
         coalesce(CAST(CustomerFlags.ispaymentplanestablished AS INT64), 0) AS paymentplanestablishedflag,
         coalesce(CAST(CustomerFlags.isvrb AS INT64), 0) AS vrbflag,
         coalesce(CAST(CustomerFlags.iscitationissued AS INT64), 0) AS citationissuedflag,
         coalesce(CAST(CustomerFlags.isbankruptcy AS INT64), 0) AS bankruptcyflag,
         coalesce(CAST(CustomerFlags.iswriteoff AS INT64), 0) AS writeoffflag,
         coalesce(CAST( TollPlus_tp_customer_attributes.isgroundtransportation AS INT64), 0) AS groundtransportationflag,
         coalesce(CAST( TollPlus_tp_customer_attributes.autorecalcreplamt AS INT64), 0) AS autorecalcreplamtflag,
         coalesce(CustomerFlagDates.autorebillfailedflag, -1) AS autorebillfailedflag,
         CustomerFlagDates.autorebillfailed_startdate,
         coalesce(CAST(CustomerFlagDates.expiredcreditcardflag AS INT64), -1) AS expiredcreditcardflag,
         CustomerFlagDates.expiredcreditcard_startdate,
         
         
         -- :: NegBalanceFlag, LowBalanceFlag for TollTag Accounts
         coalesce(CAST(CASE
                           WHEN TollPlus_tp_customers.usertypeid NOT IN(2, 3)
                                OR TollPlus_tp_customers.accountstatusid IN(16, 20) THEN -1
                           WHEN Customer_Balances.tolltagacctbalance < 0 THEN 1
                           ELSE 0
                       END AS INT64), -1) AS tolltagacctnegbalanceflag,
         coalesce(CAST(CASE
                           WHEN TollPlus_tp_customers.usertypeid NOT IN(2, 3)
                                OR TollPlus_tp_customers.accountstatusid IN(16, 20) THEN -1
                           WHEN Customer_Balances.tolltagacctbalance <= coalesce(TollPlus_TP_Customer_Attributes.thresholdamount, 0) THEN 1
                           ELSE 0
                       END AS INT64), -1) AS tolltagacctlowbalanceflag,
         TollPlus_tp_customer_attributes.thresholdamount,
         TollPlus_tp_customer_balance_alert_facts.lowbalancedate,
         TollPlus_tp_customer_balance_alert_facts.negbalancedate,
         
         -- :: ZipCashToTollTag and TollTagToZipCash Transitions. Tip. If RegCustRefID value is present on Zip Cash accounts, they are linked to TollTag account RegCustRefID. Figure out what kind of transition is it! 
         coalesce(link2zc.linktolltagcustomerid, link2tt.linktolltagcustomerid, -1) AS linktolltagcustomerid,
         coalesce(link2zc.zipcashtotolltagflag, link2tt.zipcashtotolltagflag, CASE
                                                                                  WHEN TollPlus_tp_customers.usertypeid IN(2, 3)
                                                                                       AND TollPlus_Plans.planname = 'Prepaid'
                                                                                       OR TollPlus_tp_customers.usertypeid = 11 THEN 0
                                                                                  ELSE -1
                                                                              END) AS zipcashtotolltagflag,
         coalesce(link2zc.zipcashtotolltagdate, link2tt.zipcashtotolltagdate) AS zipcashtotolltagdate,
         coalesce(link2zc.tolltagtozipcashflag, link2tt.tolltagtozipcashflag, CASE
                                                                                  WHEN TollPlus_tp_customers.usertypeid IN(2, 3)
                                                                                       AND TollPlus_Plans.planname = 'Prepaid'
                                                                                       OR TollPlus_tp_customers.usertypeid = 11 THEN 0
                                                                                  ELSE -1
                                                                              END) AS tolltagtozipcashflag,
         coalesce(link2zc.tolltagtozipcashdate, link2tt.tolltagtozipcashdate) AS tolltagtozipcashdate,
         CASE
             WHEN TollPlus_tp_customers.usertypeid IN(2,
                                             3)
                  AND TollPlus_Plans.planname = 'Prepaid' THEN CASE
                                                          WHEN link2tt.linktolltagcustomerid IS NULL
                                                               OR sd.accountcreatedate < link2tt.firstzipcashacctcreatedate THEN 1
                                                          ELSE 0
                                                      END
             WHEN TollPlus_tp_customers.usertypeid = 11 THEN CASE
                                                        WHEN link2zc.linktolltagcustomerid IS NULL
                                                             OR sd.accountcreatedate < link2zc.tolltagacctcreatedate THEN 1
                                                        ELSE 0
                                                    END
             ELSE -1
         END AS directacctflag,
         
         
         -- FYI. Validation helper or additional info columns
         CAST(CASE
                  WHEN TollPlus_tp_customers.usertypeid IN(2, 3) THEN 0
                  ELSE link2zc.seq1
              END AS INT64) AS seq1,
         CAST(CASE
                  WHEN TollPlus_tp_customers.usertypeid IN(2, 3) THEN 0
                  ELSE link2zc.seq2
              END AS INT64) AS seq2,
         link2zc.tolltagacctcreatedate AS zc_tolltagacctcreatedate,
         link2tt.zipcashacctcount,
         link2tt.firstzipcashcustomerid,
         link2tt.firstzipcashacctcreatedate,
         link2tt.lastzipcashcustomerid,
         link2tt.lastzipcashacctcreatedate,
         
         
                  
         
         -- :: Account Status Dates and related attributes
         sd.accountcreatedate,
         sd.accountcreatedby,
         sd.accountcreatechannelid,
         sd.accountcreatechannelname,
         sd.accountcreatechanneldesc,
         sd.accountcreateposid,
         sd.accountopendate,
         sd.accountopenedby,
         sd.accountopenchannelid,
         sd.accountopenchannelname,
         sd.accountopenchanneldesc,
         sd.accountopenposid,
         sd.accountlastactivedate,
         sd.accountlastactiveby,
         sd.accountlastactivechannelid,
         sd.accountlastactivechannelname,
         sd.accountlastactivechanneldesc,
         sd.accountlastactiveposid,
         sd.accountlastclosedate,
         sd.accountlastcloseby,
         sd.accountlastclosechannelid,
         sd.accountlastclosechannelname,
         sd.accountlastclosechanneldesc,
         sd.accountlastcloseposid,
         
         
         -- :: Misc
         ud.updateddate AS updateddate,
         CAST( TollPlus_tp_customers.lnd_updatedate AS DATETIME) AS lnd_updatedate,
         current_datetime() AS edw_updatedate


		/*
		SELECT 
			      TP_Customers.CustomerID
			    , CASE  WHEN TP_Customers.UserTypeID in (2,3) AND TollPlus_Plans.PlanName ='Prepaid' THEN 'TagStore'
			    		WHEN TP_Customers.UserTypeID in (2,3) AND Plans.PlanName ='Postpaid' THEN 'Fleet'
			    		WHEN TP_Customers.UserTypeID = 11 THEN 'Zipcash'
			      END AS AccountCategoryDesc
			    , SD.AccountCreateDate
			    , AccountStatus.AccountStatusDesc
			    , AccountStatusDate
			    --:: NegBalanceFlag, LowBalanceFlag for TollTag Accounts
			    , ISNULL(CAST(CASE WHEN AccountTypeID NOT IN (2,3) not Toll Tag OR TP_Customers.AccountStatusID IN (16,20) In Progress, Closed THEN -1 Not Applicable
			    				   WHEN Customer_Balances.TollTagAcctBalance < 0 THEN 1 ELSE 0 END AS SMALLINT),-1) TollTagAcctNegBalanceFlag
			    , ISNULL(CAST(CASE WHEN AccountTypeID NOT IN (2,3) Toll Tag OR TP_Customers.AccountStatusID IN (16,20) In Progress, Closed THEN -1 Not Applicable
			    				   WHEN Customer_Balances.TollTagAcctBalance <= ISNULL(TollPlus.ThresholdAmount,0) THEN 1 ELSE 0 END AS SMALLINT),-1) TollTagAcctLowBalanceFlag
			    , TollPlus.ThresholdAmount
			    , Customer_Balances.TollTagAcctBalance
			    , TP_Customer_Balance_Alert_Facts.LowBalanceDate
			    , TP_Customer_Balance_Alert_Facts.NegBalanceDate
	
			SELECT COALESCE(Link2ZC.LinkTollTagCustomerID,Link2TT.LinkTollTagCustomerID,-1) LinkTollTagCustomerID
				, TP_Customers.CustomerID
				, SD.AccountCreateDate
				, FirstName, LastName, City
			    , CASE  WHEN TP_Customers.UserTypeID in (2,3) AND Plans.PlanName ='Prepaid' THEN 'TagStore'
			    		WHEN TP_Customers.UserTypeID in (2,3) AND Plans.PlanName ='Postpaid' THEN 'Fleet'
			    		WHEN TP_Customers.UserTypeID = 11 THEN 'Zipcash'
			      END AS AccountCategoryDesc
				, AccountStatusDesc, AccountStatusDate, CASE WHEN TP_Customers.UserTypeID IN (2,3) AND Plans.PlanName ='Prepaid' THEN 0 ELSE Seq1 END Seq1, CASE WHEN TP_Customers.UserTypeID IN (2,3) AND Plans.PlanName ='Prepaid' THEN 0 ELSE Seq2 END Seq2
				--:: ZipCashToTollTag and TollTagToZipCash Transitions. Tip. If RegCustRefID value is present on Zip Cash accounts, they are linked to TollTag account RegCustRefID. Figure out what kind of transition is it! 
				, COALESCE(Link2ZC.ZipCashToTollTagFlag, Link2TT.ZipCashToTollTagFlag, CASE WHEN TP_Customers.UserTypeID IN (2,3) AND Plans.PlanName ='Prepaid' OR TP_Customers.UserTypeID = 11 Toll Tag, ZipCash THEN 0 ELSE -1 END) ZipCashToTollTagFlag
				, COALESCE(Link2ZC.ZipCashToTollTagDate,Link2TT.ZipCashToTollTagDate) ZipCashToTollTagDate
				, COALESCE(Link2ZC.TollTagToZipCashFlag, Link2TT.TollTagToZipCashFlag, CASE WHEN TP_Customers.UserTypeID IN (2,3) AND Plans.PlanName ='Prepaid' OR TP_Customers.UserTypeID = 11 Toll Tag, ZipCash THEN 0 ELSE -1 END) TollTagToZipCashFlag
				, COALESCE(Link2ZC.TollTagToZipCashDate,Link2TT.TollTagToZipCashDate) TollTagToZipCashDate
				, CASE WHEN TP_Customers.UserTypeID IN (2,3) AND Plans.PlanName ='Prepaid' TollTag
					   THEN CASE WHEN Link2TT.LinkTollTagCustomerID IS NULL OR SD.AccountCreateDate < Link2TT.FirstZipCashAcctCreateDate THEN 1 ELSE 0 END -- Tip. Read < as "before", > as "after"
					   WHEN TP_Customers.UserTypeID = 11 ZipCash
					   THEN CASE WHEN Link2ZC.LinkTollTagCustomerID IS NULL OR SD.AccountCreateDate < Link2ZC.TollTagAcctCreateDate THEN 1 ELSE 0 END
					   ELSE -1
				  END DirectAcctFlag
				-- FYI. Validation helper or additional info columns
				, CAST(CASE WHEN TP_Customers.UserTypeID IN (2,3) TollTag THEN 0 ELSE Link2ZC.Seq1 END AS SMALLINT) Seq1
				, CAST(CASE WHEN TP_Customers.UserTypeID IN (2,3) TollTag THEN 0 ELSE Link2ZC.Seq2 END AS SMALLINT) Seq2
				, Link2ZC.TollTagAcctCreateDate AS ZC_TollTagAcctCreateDate
				, Link2TT.ZipCashAcctCount, Link2TT.FirstZipCashCustomerID, Link2TT.FirstZipCashAcctCreateDate, Link2TT.LastZipCashCustomerID, Link2TT.LastZipCashAcctCreateDate

				--:: Account Status Dates and related attributes
				, SD.AccountCreateDate, SD.AccountCreatedBy, SD.AccountCreateChannelID, SD.AccountCreateChannelName, SD.AccountCreateChannelDesc, SD.AccountCreatePOSID
				, SD.AccountOpenDate, SD.AccountOpenedBy, SD.AccountOpenChannelID, SD.AccountOpenChannelName, SD.AccountOpenChannelDesc, SD.AccountOpenPOSID
				, SD.AccountLastActiveDate, SD.AccountLastActiveBy, SD.AccountLastActiveChannelID, SD.AccountLastActiveChannelName, SD.AccountLastActiveChannelDesc, SD.AccountLastActivePOSID
				, SD.AccountLastCloseDate, SD.AccountLastCloseBy, SD.AccountLastCloseChannelID, SD.AccountLastCloseChannelName, SD.AccountLastCloseChannelDesc, SD.AccountLastClosePOSID
		
		*/




		-- SELECT COUNT(1)
  FROM LND_TBOS.TollPlus_TP_Customers
  LEFT OUTER JOIN LND_TBOS.TollPlus_TP_Customer_Contacts ON TollPlus_TP_Customer_Contacts.customerid = TollPlus_TP_Customers.customerid
  AND TollPlus_TP_Customer_Contacts.nametype = 'Primary'
  AND TollPlus_TP_Customer_Contacts.iscommunication = 1
  AND TollPlus_TP_Customers.lnd_updatetype <> 'D'
  AND TollPlus_TP_Customer_Contacts.lnd_updatetype <> 'D'
  LEFT OUTER JOIN LND_TBOS.TollPlus_TP_Customer_Addresses ON TollPlus_TP_Customer_Addresses.customerid = TollPlus_TP_Customers.customerid
  
  --  AND TP_Customer_Addresses.IsValid = 1 -- Show bad address also
  
  AND TollPlus_TP_Customer_Addresses.isactive = 1
  AND TollPlus_TP_Customer_Addresses.iscommunication = 1
  AND TollPlus_TP_Customer_Addresses.lnd_updatetype <> 'D'
  LEFT OUTER JOIN LND_TBOS.TollPlus_TP_Customer_Attributes ON TollPlus_TP_Customer_Attributes.customerid = TollPlus_tp_customers.customerid
  AND TollPlus_tp_customer_attributes.lnd_updatetype <> 'D'
  LEFT OUTER JOIN LND_TBOS.TollPlus_TP_Customer_Plans ON TollPlus_tp_customers.customerid = TollPlus_tp_customer_plans.customerid
  AND TollPlus_tp_customer_plans.lnd_updatetype <> 'D'
  LEFT OUTER JOIN LND_TBOS.TollPlus_Plans ON TollPlus_tp_customer_plans.planid = TollPlus_plans.planid
  AND TollPlus_plans.lnd_updatetype <> 'D'
  LEFT OUTER JOIN LND_TBOS.TollPlus_TP_Customer_Business ON TollPlus_tp_customers.customerid = TollPlus_tp_customer_business.customerid
  AND TollPlus_tp_customer_business.lnd_updatetype <> 'D'
  LEFT OUTER JOIN EDW_TRIPS.Dim_AccountType AS accounttype ON TollPlus_tp_customers.usertypeid = accounttype.accounttypeid
  LEFT OUTER JOIN EDW_TRIPS.Dim_AccountStatus AS accountstatus ON TollPlus_tp_customers.accountstatusid = accountstatus.accountstatusid
  LEFT OUTER JOIN EDW_TRIPS.Dim_CustomerStatus AS customerstatus ON TollPlus_tp_customers.customerstatusid = customerstatus.customerstatusid
  LEFT OUTER JOIN EDW_TRIPS.Dim_RevenueType AS revenuetype ON TollPlus_tp_customer_attributes.nonrevenuetypeid = revenuetype.revenuetypeid
  LEFT OUTER JOIN EDW_TRIPS.Dim_RevenueCategory AS revenuecategory ON TollPlus_tp_customers.revenuecategoryid = revenuecategory.revenuecategoryid
  LEFT OUTER JOIN EDW_TRIPS.Dim_Channel AS channel ON TollPlus_tp_customers.channelid = channel.channelid
  LEFT OUTER JOIN EDW_TRIPS.Dim_AutoReplenishment AS autoreplenishment ON TollPlus_tp_customer_attributes.autoreplenishmentid = autoreplenishment.autoreplenishmentid
  LEFT OUTER JOIN _SESSION.Customer_Balances AS Customer_Balances ON Customer_Balances.customerid = TollPlus_tp_customers.customerid
  LEFT OUTER JOIN _SESSION.CustomerPhones AS CustomerPhones ON CustomerPhones.customerid = TollPlus_tp_customers.customerid
  LEFT OUTER JOIN _SESSION.CustomerFlags AS CustomerFlags ON CustomerFlags.customerid = TollPlus_tp_customers.customerid
  LEFT OUTER JOIN _SESSION.CustomerFlagDates AS CustomerFlagDates ON CustomerFlagDates.customerid = TollPlus_tp_customers.customerid
  INNER JOIN _SESSION.Customer_UpdatedDates  AS ud ON ud.customerid = TollPlus_tp_customers.customerid
  LEFT OUTER JOIN EDW_TRIPS_STAGE.AccountStatusDetail AS sd ON sd.customerid = TollPlus_tp_customers.customerid
  LEFT OUTER JOIN LND_TBOS.TollPlus_tp_customer_balance_alert_facts ON TollPlus_tp_customer_balance_alert_facts.customerid = TollPlus_tp_customers.customerid
  LEFT OUTER JOIN _SESSION.TT_CustTransition AS link2tt ON link2tt.linktolltagcustomerid = TollPlus_tp_customers.customerid
  LEFT OUTER JOIN _SESSION.ZC_CustTransition AS link2zc ON link2zc.zipcashcustomerid = TollPlus_tp_customers.customerid 
   LEFT OUTER JOIN EDW_TRIPS.Dim_ZipCode as zipcodes on zipcodes.zipcode = TollPlus_tp_customer_addresses.zip1; 
 -- LEFT OUTER JOIN LND_TBOS.TollPlus_ZipCodes AS zipcodes ON zipcodes.zipcode = TollPlus_tp_customer_addresses.zip1 AND zipcodes.lnd_updatetype <> 'D';

	-- WHERE TP_Customers.CustomerID = 10  OR TP_Customers.RegCustRefID = 137
	-- ORDER BY COALESCE(Link2ZC.LinkTollTagCustomerID,ZipCashCustomerID, TP_Customers.CustomerID), SD.AccountCreateDate
SET log_message = 'Loaded EDW_TRIPS.Dim_Customer';

CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, log_message, 'I', -1, NULL);

-- :: Insert CustomerID -1 row

INSERT INTO EDW_TRIPS.Dim_Customer (customerid, title, firstname, middleinitial, lastname, suffix, addresstype, addressline1, addressline2, city, state, county, country, zipcode, plus4, addressupdateddate, mobilephonenumber, homephonenumber, workphonenumber, preferredphonetype, customerplanid, customerplandesc, accountcategoryid, accountcategorydesc, accounttypeid, accounttypecode, accounttypedesc, accountstatusid, accountstatuscode, accountstatusdesc, accountstatusdate, customerstatusid, customerstatuscode, customerstatusdesc, revenuecategoryid, revenuecategorycode, revenuecategorydesc, revenuetypeid, revenuetypecode, revenuetypedesc, channelid, channelname, channeldesc, rebillamount, rebilldate, autoreplenishmentid, autoreplenishmentcode, autoreplenishmentdesc, tolltagacctbalance, zipcashcustbalance, refundbalance, tolltagdepositbalance, fleetacctbalance, companycode, companyname, fleetflag, badaddressflag, incollectionsflag, hvflag, adminhearingscheduledflag, paymentplanestablishedflag, vrbflag, citationissuedflag, bankruptcyflag, writeoffflag, groundtransportationflag, autorecalcreplamtflag, autorebillfailedflag, autorebillfailed_startdate, expiredcreditcardflag, expiredcreditcard_startdate, tolltagacctnegbalanceflag, tolltagacctlowbalanceflag, thresholdamount, linktolltagcustomerid, zipcashtotolltagflag, zipcashtotolltagdate, tolltagtozipcashflag, tolltagtozipcashdate, directacctflag, zipcashacctcount, firstzipcashacctcreatedate, lastzipcashacctcreatedate, accountcreatedate, accountcreatedby, accountcreatechannelid, accountcreatechannelname, accountcreatechanneldesc, accountcreateposid, accountopendate, accountopenedby, accountopenchannelid, accountopenchannelname, accountopenchanneldesc, accountopenposid, accountlastactivedate, accountlastactiveby, accountlastactivechannelid, accountlastactivechannelname, accountlastactivechanneldesc, accountlastactiveposid, accountlastclosedate, accountlastcloseby, accountlastclosechannelid, accountlastclosechannelname, accountlastclosechanneldesc, accountlastcloseposid, updateddate, lnd_updatedate, edw_updatedate)
SELECT -1 AS customerid,
       CAST(NULL AS STRING) AS title,
       CAST(NULL AS STRING) AS firstname,
       CAST(NULL AS STRING) AS middleinitial,
       CAST(NULL AS STRING) AS lastname,
       CAST(NULL AS STRING) AS suffix,
       'UNK' AS addresstype,
       'Unknown' AS addressline1,
       CAST(NULL AS STRING) AS addressline2,
       'Unknown' AS city,
       'UNK' AS state,
       'UNK' AS county,
       'UNK' AS country,
       'UNK' AS zipcode,
       CAST(NULL AS STRING) AS plus4,
       CAST(NULL AS DATETIME) AS addressupdateddate,
       CAST(NULL AS STRING) AS mobilephonenumber,
       CAST(NULL AS STRING) AS homephonenumber,
       CAST(NULL AS STRING) AS workphonenumber,
       CAST(NULL AS STRING) AS preferredphonetype,
       -1 AS customerplanid,
       'Unknown' AS customerplandesc,
       -1 AS accountcategoryid,
       'Unknown' AS accountcategorydesc,
       -1 AS accounttypeid,
       'Unknown' AS accounttypecode,
       'Unknown' AS accounttypedesc,
       -1 AS accountstatusid,
       'Unknown' AS accountstatuscode,
       'Unknown' AS accountstatusdesc,
       DATE '1900-01-01' AS accountstatusdate,
       -1 AS customerstatusid,
       'Unknown' AS customerstatuscode,
       'Unknown' AS customerstatusdesc,
       -1 AS revenuecategoryid,
       'Unknown' AS revenuecategorycode,
       'Unknown' AS revenuecategorydesc,
       -1 AS revenuetypeid,
       'Unknown' AS revenuetypecode,
       'Unknown' AS revenuetypedesc,
       -1 AS channelid,
       'Unknown' AS channelname,
       'Unknown' AS channeldesc,
       0 AS rebillamount,
       NULL AS rebilldate,
       -1 AS autoreplenishmentid,
       'Unknown' AS autoreplenishmentcode,
       'Unknown' AS autoreplenishmentdesc,
       NULL AS tolltagacctbalance,
       NULL AS zipcashcustbalance,
       NULL AS refundbalance,
       NULL AS tolltagdepositbalance,
       NULL AS fleetacctbalance,
       CAST(NULL AS STRING) AS companycode,
       NULL AS companyname,
       0 AS fleetflag,
       0 AS badaddressflag,
       0 AS incollectionsflag,
       0 AS hvflag,
       0 AS adminhearingscheduledflag,
       0 AS paymentplanestablishedflag,
       0 AS vrbflag,
       0 AS citationissuedflag,
       0 AS bankruptcyflag,
       0 AS writeoffflag,
       0 AS groundtransportationflag,
       0 AS autorecalcreplamtflag,
       -1 AS autorebillfailedflag,
       NULL AS autorebillfailed_startdate,
       -1 AS expiredcreditcardflag,
       NULL AS expiredcreditcard_startdate,
       -1 AS tolltagacctnegbalanceflag,
       -1 AS tolltagacctlowbalanceflag,
       40 AS thresholdamount,
       0 AS linktolltagcustomerid,
       -1 AS zipcashtotolltagflag,
       NULL AS zipcashtotolltagdate,
       -1 AS tolltagtozipcashflag,
       NULL AS tolltagtozipcashdate,
       -1 AS directacctflag,
       NULL AS zipcashacctcount,
       NULL AS firstzipcashacctcreatedate,
       NULL AS lastzipcashacctcreatedate,
       NULL AS accountcreatedate,
       NULL AS accountcreatedby,
       NULL AS accountcreatechannelid,
       NULL AS accountcreatechannelname,
       NULL AS accountcreatechanneldesc,
       NULL AS accountcreateposid,
       NULL AS accountopendate,
       NULL AS accountopenedby,
       NULL AS accountopenchannelid,
       NULL AS accountopenchannelname,
       NULL AS accountopenchanneldesc,
       NULL AS accountopenposid,
       NULL AS accountlastactivedate,
       NULL AS accountlastactiveby,
       NULL AS accountlastactivechannelid,
       NULL AS accountlastactivechannelname,
       NULL AS accountlastactivechanneldesc,
       NULL AS accountlastactiveposid,
       NULL AS accountlastclosedate,
       NULL AS accountlastcloseby,
       NULL AS accountlastclosechannelid,
       NULL AS accountlastclosechannelname,
       NULL AS accountlastclosechanneldesc,
       NULL AS accountlastcloseposid,
       NULL AS updateddate,
       CAST(NULL AS DATETIME) AS lnd_updatedate,
       current_datetime() AS edw_updatedate ;
 
 -- Table swap!
 --TableSwap is Not Required, using  Create or Replace Table
 --CALL EDW_TRIPS_SUPPORT.TableSwap('EDW_TRIPS.Dim_Customer_NEW', 'EDW_TRIPS.Dim_Customer');

CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, 'Completed full load', 'I', NULL, NULL);
IF trace_flag = 1 THEN
  SELECT
      'EDW_TRIPS.Dim_Customer' AS tablename,
      *
    FROM
      EDW_TRIPS.dim_customer
  ORDER BY
    2 DESC LIMIT 1000
  ;
END IF;

-- Show results
IF trace_flag = 1 THEN 
--CALL EDW_TRIPS-SUPPORT.FromLog(log_source, log_start_date);
--SELECT log_source,log_start_date;
END IF;

IF trace_flag = 1 THEN
SELECT 'EDW_TRIPS.Dim_Customer' AS tablename,
       *
FROM EDW_TRIPS.Dim_Customer
ORDER BY 2 DESC
LIMIT 1000;

END IF;

EXCEPTION WHEN ERROR THEN BEGIN DECLARE error_message STRING DEFAULT @@error.message;

CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, error_message, 'E', NULL, NULL);
RAISE USING MESSAGE = error_message;
-- Rethrow the error!

END;

END;
/*
--===============================================================================================================
-- DEVELOPER TESTING ZONE to thoroughly test the code for various scenarios
--===============================================================================================================
EXEC dbo.Dim_Customer_Full_Load

EXEC Utility.FromLog 'dbo.Dim_Customer', 35
SELECT TOP 100 'dbo.Dim_Customer' Table_Name, * FROM dbo.Dim_Customer ORDER BY 2

--:: Lookup tables in dbo.dim_Customer
SELECT * FROM dbo.dim_AccountCategory	  ORDER BY 1
SELECT * FROM dbo.dim_AccountStatus		  ORDER BY 1
SELECT * FROM dbo.dim_AccountType		  ORDER BY 1
SELECT * FROM dbo.dim_Channel			  ORDER BY 1
SELECT * FROM dbo.dim_CustomerPlan		  ORDER BY 1
SELECT * FROM dbo.dim_CustomerStatus	  ORDER BY 1
SELECT * FROM dbo.dim_RevenueCategory	  ORDER BY 1
SELECT * FROM dbo.dim_RevenueType		  ORDER BY 1
SELECT * FROM dbo.Dim_AutoReplenishment   ORDER BY 1

--===============================================================================================================
-- USEFUL DATA VALIDATION SCRIPTS for post prod move monitoring or for others to not reinvent the wheel
--===============================================================================================================

--:: Quick Data Profiling
SELECT 'TP_Customers' TableName, CustomerID, MAX(UpdatedDate) LastUpdatedDate FROM LND_TBOS.TollPlus.TP_Customers GROUP BY CustomerID UNION
SELECT 'TP_Customer_Contacts' TableName, CustomerID, MAX(UpdatedDate) LastUpdatedDate FROM LND_TBOS.TollPlus.TP_Customer_Contacts GROUP BY CustomerID UNION
SELECT 'TP_Customer_Addresses' TableName, CustomerID, MAX(UpdatedDate) LastUpdatedDate FROM LND_TBOS.TollPlus.TP_Customer_Addresses GROUP BY CustomerID UNION
SELECT 'TP_Customer_Plans' TableName, CustomerID, MAX(UpdatedDate) LastUpdatedDate FROM LND_TBOS.TollPlus.TP_Customer_Plans GROUP BY CustomerID UNION
SELECT 'TP_Customer_Flags' TableName, CustomerID, MAX(UpdatedDate) LastUpdatedDate FROM LND_TBOS.TollPlus.TP_Customer_Flags GROUP BY CustomerID   

*/


END;