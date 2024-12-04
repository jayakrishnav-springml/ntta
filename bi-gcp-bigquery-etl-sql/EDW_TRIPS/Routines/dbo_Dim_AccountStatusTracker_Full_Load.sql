CREATE OR REPLACE PROCEDURE `EDW_TRIPS.Dim_AccountStatusTracker_Full_Load`()
BEGIN 
/*
###################################################################################################################
Proc Description: 
-------------------------------------------------------------------------------------------------------------------
Load dbo.Dim_AccountStatusTracker table. 
===================================================================================================================
Change Log:
-------------------------------------------------------------------------------------------------------------------
CHG0040056	Shankar			2021-11-24	New!
CHG0042384	Shankar			2022-12-20  Added RegCustRefID and UserTypeID in stage table for ZC/TT transition load
===================================================================================================================
Example:
-------------------------------------------------------------------------------------------------------------------
EXEC dbo.Dim_AccountStatusTracker_Full_Load
SELECT * FROM Utility.ProcessLog WHERE LogSource LIKE '%Dim_AccountStatusTracker%' ORDER BY 1 DESC 
SELECT TOP 100 'dbo.Dim_AccountStatusTracker' Table_Name, * FROM dbo.Dim_AccountStatusTracker ORDER BY 2 DESC, 3
SELECT TOP 1000 'Stage.AccountStatusDetail' TableName, * FROM Stage.AccountStatusDetail ORDER BY 2 DESC
###################################################################################################################
*/
DECLARE log_source STRING DEFAULT 'EDW_TRIPS.Dim_AccountStatusTracker_Full_Load'; 
DECLARE log_start_date DATETIME; 
DECLARE log_message STRING; 
DECLARE trace_flag INT64 DEFAULT 0;
BEGIN 
DECLARE ROW_COUNT INT64;
SET log_start_date = current_datetime('America/Chicago'); 
CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, 'Started full load', 'I', CAST(NULL AS INT64), CAST(NULL AS STRING)); 

--===============================================================================================================
--:: Get Customer Activity from TRIPS (History  + Current)
--===============================================================================================================



-- DROP TABLE IF EXISTS _SESSION.trips_customerhistory;

CREATE OR REPLACE
TEMPORARY TABLE _SESSION.trips_customerhistory AS
SELECT c.customerid,
       'TRIPS' AS datasource,
       'History' AS tablesource,
       cs.customerstatusdesc,
       c.usertypeid AS accounttypeid,
       t.accounttypecode,
       t.accounttypedesc,
       c.accountstatusid,
       s.accountstatuscode,
       s.accountstatusdesc,
       c.accountstatusdate,
       c.createddate,
       c.createduser,
       c.updateddate,
       c.updateduser,
       c.icnid,
       c.channelid,
       c.histid
FROM LND_TBOS.History_TP_Customers AS c
INNER JOIN EDW_TRIPS.Dim_AccountStatus AS s ON c.accountstatusid = s.accountstatusid
INNER JOIN EDW_TRIPS.Dim_AccountType AS t ON c.usertypeid = t.accounttypeid
INNER JOIN EDW_TRIPS.Dim_CustomerStatus AS cs ON c.customerstatusid = cs.customerstatusid
UNION DISTINCT
SELECT c.customerid,
       'TRIPS' AS datasource,
       'Current' AS tablesource,
       cs.customerstatusdesc,
       c.usertypeid AS accounttypeid,
       t.accounttypecode,
       t.accounttypedesc,
       c.accountstatusid,
       s.accountstatuscode,
       s.accountstatusdesc,
       c.accountstatusdate,
       c.createddate,
       c.createduser,
       c.updateddate,
       c.updateduser,
       c.icnid,
       c.channelid,
       CAST(NULL AS INT64) AS histid
FROM LND_TBOS.TollPlus_TP_Customers AS c
INNER JOIN EDW_TRIPS.Dim_AccountStatus AS s ON c.accountstatusid = s.accountstatusid
INNER JOIN EDW_TRIPS.Dim_AccountType AS t ON c.usertypeid = t.accounttypeid
INNER JOIN EDW_TRIPS.Dim_CustomerStatus AS cs ON c.customerstatusid = cs.customerstatusid ;

-- ORDER BY CustomerID DESC, AccountStatusDate, UpdatedDate

SET log_message = 'Loaded #TRIPS_CustomerHistory'; 
CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, log_message, 'I', -1, CAST(NULL AS STRING));

/*
SELECT COUNT(*) [#TRIPS_CustomerHistory] FROM #TRIPS_CustomerHistory 
SELECT TOP 1000 * FROM #TRIPS_CustomerHistory ORDER BY CustomerID DESC, AccountStatusDate, UpdatedDate
SELECT * FROM #TRIPS_CustomerHistory WHERE CustomerID = 2010386956 ORDER BY CustomerID DESC, AccountStatusDate, UpdatedDate -- IN (804854271,6680625)
SELECT AccountStatusID, COUNT(1) [#TRIPS_CustomerHistory Rows] FROM #TRIPS_CustomerHistory GROUP BY AccountStatusID ORDER BY 2 DESC
SELECT CustomerID, AccountStatusID, CONVERT(DATE, ch.AccountStatusDate), COUNT(1) RC FROM #TRIPS_CustomerHistory ch GROUP BY CustomerID, AccountStatusID, CONVERT(DATE, ch.AccountStatusDate) HAVING COUNT(1) > 1 ORDER BY 1 DESC,2
*/

--:: Track activities not found in TP_Customer_AccStatus_Tracker! :-)

--DROP TABLE IF EXISTS _SESSION.missing_in_accstatus_tracker;
CREATE OR REPLACE
TEMPORARY TABLE _SESSION.missing_in_accstatus_tracker AS
SELECT DISTINCT trips_customerhistory.customerid,
                trips_customerhistory.accountstatusid,
                CAST(trips_customerhistory.accountstatusdate AS DATE) AS accountstatusdate
FROM _SESSION.trips_customerhistory AS trips_customerhistory
EXCEPT DISTINCT
SELECT DISTINCT TollPlus_TP_Customer_AccStatus_Tracker.customerid,
                TollPlus_TP_Customer_AccStatus_Tracker.accountstatusid,
                CAST(TollPlus_TP_Customer_AccStatus_Tracker.accountstatusdate AS DATE) AS accountstatusdate
FROM LND_TBOS.TollPlus_TP_Customer_AccStatus_Tracker ;
SET log_message = 'Loaded #Missing_in_AccStatus_Tracker'; 
CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, log_message, 'I', -1, CAST(NULL AS STRING));

/*
SELECT COUNT(*) [#Missing_in_AccStatus_Tracker] FROM #Missing_in_AccStatus_Tracker 
SELECT TOP 1000 * FROM #Missing_in_AccStatus_Tracker ORDER BY CustomerID DESC, AccountStatusDate 
SELECT COUNT(1) [TP_Customer_AccStatus_Tracker] FROM LND_TBOS.TollPlus.TP_Customer_AccStatus_Tracker WHERE CustomerID IN (804854271,6680625) 
SELECT AccountStatusID, COUNT(1) [TP_Customer_AccStatus_Tracker Rows] FROM LND_TBOS.TollPlus.TP_Customer_AccStatus_Tracker WHERE CustomerID IN (804854271,6680625)  GROUP BY AccountStatusID ORDER BY 2 DESC
SELECT AccountStatusID, COUNT(1) [#Missing_in_AccStatus_Tracker Rows] FROM #Missing_in_AccStatus_Tracker GROUP BY AccountStatusID ORDER BY 2 DESC
*/ 

--:: Get complete picture of Account Status changes done in TRIPS

--DROP TABLE IF EXISTS EDW_TRIPS_STAGE.TRIPS_AccountStatusTracker;
CREATE OR REPLACE TABLE EDW_TRIPS_STAGE.TRIPS_AccountStatusTracker CLUSTER BY CustomerID AS 
SELECT s.customerid,
       s.datasource,
       s.tablesource,
       s.customerstatusdesc,
       s.accounttypeid,
       s.accounttypecode,
       s.accounttypedesc,
       s.accountstatusid,
       s.accountstatuscode,
       s.accountstatusdesc,
       s.accountstatusdate,
       s.createddate,
       s.createduser,
       s.updateddate,
       s.updateduser,
       s.channelid,
       TollPlus_ICN.icnid,
       TollPlus_ICN.userid AS employeeid,
       concat(cc_emp.firstname, CASE WHEN cc_emp.firstname <> cc_emp.lastname THEN concat(' ',cc_emp.lastname ) else '' END) AS employeename,
       lr.locationid AS posid,
       s.trips_accstatushistid,
       s.trips_histid

       -- SELECT COUNT(1)

FROM
  (SELECT ast.customerid,
          'TRIPS' AS datasource,
          'AccStatusTracker' AS tablesource,
          cs.customerstatusdesc,
          c.usertypeid AS accounttypeid,
          t.accounttypecode,
          t.accounttypedesc,
          ast.accountstatusid,
          s_0.accountstatuscode,
          s_0.accountstatusdesc,
          ast.accountstatusdate,
          ast.createddate,
          ast.createduser,
          ast.updateddate,
          ast.updateduser,
          ast.icnid,
          ast.channelid,
          ast.accstatushistid AS trips_accstatushistid,
          CAST(NULL AS INT64) AS trips_histid

          -- SELECT COUNT(1)

   FROM LND_TBOS.TollPlus_TP_Customer_AccStatus_Tracker AS ast
   INNER JOIN LND_TBOS.TollPlus_TP_Customers AS c ON c.customerid = ast.customerid
   AND ast.lnd_updatetype <> 'D'
   AND c.lnd_updatetype <> 'D'
   INNER JOIN EDW_TRIPS.Dim_AccountStatus AS s_0 ON s_0.accountstatusid = ast.accountstatusid
   INNER JOIN EDW_TRIPS.Dim_Accounttype AS t ON t.accounttypeid = c.usertypeid
   INNER JOIN EDW_TRIPS.Dim_CustomerStatus AS cs ON cs.customerstatusid = c.customerstatusid
   
     --WHERE	c.CustomerID IN ()
     --ORDER BY CustomerID DESC, AccountStatusDate, UpdatedDate
     -- Add the missing activities from Cust History data
   UNION DISTINCT SELECT t.customerid,
                         t.datasource,
                         t.tablesource,
                         t.customerstatusdesc,
                         t.accounttypeid,
                         t.accounttypecode,
                         t.accounttypedesc,
                         t.accountstatusid,
                         t.accountstatuscode,
                         t.accountstatusdesc,
                         t.accountstatusdate,
                         t.createddate,
                         t.createduser,
                         t.updateddate,
                         t.updateduser,
                         t.icnid,
                         t.channelid,
                         CAST(NULL AS INT64) AS trips_accstatushistid,
                         t.histid AS trips_histid
   
   -- SELECT COUNT(1)
   
   FROM
     (SELECT ch.datasource,
             ch.tablesource,
             mast.customerid,
             ch.customerstatusdesc,
             ch.accounttypeid,
             ch.accounttypecode,
             ch.accounttypedesc,
             ch.accountstatusid,
             ch.accountstatuscode,
             ch.accountstatusdesc,
             ch.accountstatusdate,
             ch.createddate,
             ch.createduser,
             ch.updateddate,
             ch.updateduser,
             ch.icnid,
             ch.channelid,
             coalesce(ch.histid, 999999999) AS histid,
             row_number() OVER (PARTITION BY ch.customerid,
                                             ch.accountstatusid
                                ORDER BY ch.updateddate DESC, ch.icnid DESC, ch.channelid DESC) AS rn
      FROM _SESSION.missing_in_accstatus_tracker AS mast
      INNER JOIN _SESSION.trips_customerhistory AS ch ON ch.customerid = mast.customerid
      AND ch.accountstatusid = mast.accountstatusid
      AND CAST(ch.accountstatusdate AS DATE) = mast.accountstatusdate) AS t
   WHERE t.rn = 1 ) AS s

   -- ORDER BY CustomerID DESC, AccountStatusDate, UpdatedDate  

LEFT OUTER JOIN LND_TBOS.TollPlus_ICN ON TollPlus_ICN.icnid = s.icnid
LEFT OUTER JOIN LND_TBOS.RBAC_LocationRoles AS lr ON lr.locationroleid = TollPlus_ICN.locationroleid
LEFT OUTER JOIN LND_TBOS.TollPlus_TP_Customer_Contacts AS cc_emp ON cc_emp.customerid = TollPlus_ICN.userid
AND cc_emp.lnd_updatetype <> 'D' ;

-- ORDER BY s.CustomerID DESC, s.AccountStatusDate, s.UpdatedDate

SET log_message = 'Loaded Stage.TRIPS_AccountStatusTracker'; 
CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, log_message, 'I', -1, CAST(NULL AS STRING));


/*
SELECT COUNT(*) [Stage.TRIPS_AccountStatusTracker] FROM Stage.TRIPS_AccountStatusTracker 
SELECT TOP 1000 * FROM Stage.TRIPS_AccountStatusTracker ORDER BY CustomerID DESC, AccountStatusDate 
SELECT * FROM Stage.TRIPS_AccountStatusTracker WHERE CustomerID IN (804854271,6680625) ORDER BY CustomerID DESC, AccountStatusDate -- = 5942833
SELECT COUNT(1) [TP_Customer_AccStatus_Tracker] FROM LND_TBOS.TollPlus.TP_Customer_AccStatus_Tracker WHERE CustomerID IN (804854271,6680625)  
SELECT AccountStatusID, COUNT(1) [TP_Customer_AccStatus_Tracker Rows] FROM LND_TBOS.TollPlus.TP_Customer_AccStatus_Tracker WHERE CustomerID IN (804854271,6680625) GROUP BY AccountStatusID ORDER BY 2 DESC
SELECT AccountStatusID, COUNT(1) [Stage.TRIPS_AccountStatusTracker Rows] FROM Stage.TRIPS_AccountStatusTracker GROUP BY AccountStatusID ORDER BY 2 DESC
*/ 

--===============================================================================================================
--:: Load dbo.Dim_AccountStatusTracker
--===============================================================================================================



--DROP TABLE IF EXISTS EDW_TRIPS.Dim_AccountStatusTracker;
CREATE  OR REPLACE TABLE EDW_TRIPS.Dim_AccountStatusTracker CLUSTER BY CustomerID AS
SELECT ast.customerid,
       row_number() OVER (PARTITION BY ast.customerid
                          ORDER BY ast.accountstatusdate,
                                   ast.icnid DESC, ast.channelid DESC) AS accountstatusseq,
                         ast.datasource,
                         ast.tablesource,
                         ast.customerstatusdesc,
                         ast.accounttypeid,
                         ast.accounttypedesc,
                         ast.accountstatusid,
                         ast.accountstatusdesc,
                         ast.accountstatusdate AS accountstatusstartdate,
                         coalesce(date_sub(lead(ast.accountstatusdate, 1) OVER (PARTITION BY ast.customerid
                                                                                ORDER BY ast.accountstatusdate), interval 1 SECOND), CAST('9999-12-31 23:59:59' AS DATETIME)) AS accountstatusenddate,
                         ast.createddate,
                         ast.createduser,
                         ast.updateddate,
                         ast.updateduser,
                         ast.employeeid,
                         coalesce(ast.employeename, concat(cc_cust.firstname, CASE WHEN trim(cc_cust.firstname) <> trim(cc_cust.lastname) THEN concat(' ',cc_cust.lastname ) else '' END), ast.updateduser) AS username,
                         ast.channelid,
                         ch.channelname,
                         ch.channeldesc,
                         ast.posid,
                         ast.icnid,
                         ast.rite_acct_hist_seq,
                         ast.trips_accstatushistid,
                         ast.trips_histid,
                         row_number() OVER (PARTITION BY ast.customerid,
                                                         ast.accountstatusid
                                            ORDER BY ast.accountstatusdate,
                                                     ast.icnid DESC, ast.channelid DESC) AS rownumfromfirst,
                                           row_number() OVER (PARTITION BY ast.customerid,
                                                                           ast.accountstatusid
                                                              ORDER BY ast.accountstatusdate DESC, ast.icnid DESC, ast.channelid DESC) AS rownumfromlast,
                                                             current_datetime() AS edw_updatedate
FROM
  (SELECT rst.customerid,
          datasource,
          tablesource,
          cs.customerstatusdesc,
          t.accounttypeid,
          t.accounttypecode,
          t.accounttypedesc,
          rst.accountstatusid,
          s.accountstatuscode,
          s.accountstatusdesc,
          rst.accountstatusdate,
          rst.createddate,
          rst.createduser,
          rst.updateddate,
          rst.updateduser,
          CAST(NULL AS INT64) AS icnid,
          CAST(NULL AS INT64) AS channelid,
          CAST(NULL AS INT64) AS employeeid,
          CAST(NULL AS STRING) AS employeename,
          CAST(NULL AS INT64) AS posid,
          rite_acct_hist_seq,
          CAST(NULL AS INT64) AS trips_accstatushistid,
          CAST(NULL AS INT64) AS trips_histid
   FROM EDW_TRIPS_SUPPORT.RITE_AccountStatusHistory AS rst
   INNER JOIN LND_TBOS.TollPlus_TP_Customers AS c ON c.customerid = rst.customerid
   AND c.lnd_updatetype <> 'D'
   INNER JOIN EDW_TRIPS.Dim_AccountStatus AS s ON s.accountstatusid = rst.accountstatusid
   INNER JOIN EDW_TRIPS.Dim_AccountType AS t ON t.accounttypeid = c.usertypeid
   INNER JOIN EDW_TRIPS.Dim_CustomerStatus AS cs ON cs.customerstatusid = c.customerstatusid
   WHERE NOT EXISTS
       (SELECT 1
        FROM EDW_TRIPS_STAGE.TRIPS_AccountStatusTracker AS tst
        WHERE tst.customerid = rst.customerid
          AND tst.accountstatusid = rst.accountstatusid
          AND tst.accountstatusdate = rst.accountstatusdate
          AND rst.rite_histlast_rn = 1 )


     --ORDER BY RITE_HistLast_RN
     --AND RST.CustomerID IN (804854271,6680625) 
     --ORDER BY CustomerID, AccountStatusDate

   UNION DISTINCT SELECT tst.customerid,
                         tst.datasource,
                         tst.tablesource,
                         tst.customerstatusdesc,
                         tst.accounttypeid,
                         tst.accounttypecode,
                         tst.accounttypedesc,
                         tst.accountstatusid,
                         tst.accountstatuscode,
                         tst.accountstatusdesc,
                         tst.accountstatusdate,
                         tst.createddate,
                         tst.createduser,
                         tst.updateddate,
                         tst.updateduser,
                         tst.icnid,
                         tst.channelid,
                         tst.employeeid,
                         tst.employeename,
                         tst.posid,
                         CAST(NULL AS INT64) AS rite_acct_hist_seq,
                         tst.trips_accstatushistid,
                         tst.trips_histid
   FROM EDW_TRIPS_STAGE.TRIPS_AccountStatusTracker AS tst) AS ast

   --WHERE	TST.CustomerID IN (804854271,6680625) 
   --ORDER BY CustomerID, AccountStatusDate



LEFT OUTER JOIN LND_TBOS.TollPlus_TP_Customer_LogIns AS cl ON cl.username = ast.updateduser
LEFT OUTER JOIN LND_TBOS.TollPlus_TP_Customer_Contacts AS cc_cust ON cc_cust.customerid = cl.customerid
AND cc_cust.lnd_updatetype <> 'D'
LEFT OUTER JOIN EDW_TRIPS.Dim_Channel AS ch ON ch.channelid = ast.channelid ;

-- ORDER BY CustomerID, AccountStatusDate

SET log_message = 'Loaded Dim_AccountStatusTracker'; 
CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, log_message, 'I', -1, CAST(NULL AS STRING)); -- COLLECT STATISTICS is not supported in this dialect.


		/* 
		SELECT COUNT(*) [dbo.Dim_AccountStatusTracker] FROM dbo.Dim_AccountStatusTracker
		SELECT TOP 1000 * FROM dbo.Dim_AccountStatusTracker ORDER BY CustomerID DESC, AccountStatusStartDate 
		SELECT CustomerID, AccountStatusID, CONVERT(DATE, ch.AccountStatusDate), COUNT(1) RC FROM dbo.Dim_AccountStatusTracker ch GROUP BY CustomerID, AccountStatusID, CONVERT(DATE, ch.AccountStatusDate) HAVING COUNT(1) > 1
		SELECT AccountStatusID, COUNT(1) [dbo.Dim_AccountStatusTracker Rows] FROM dbo.Dim_AccountStatusTracker ch GROUP BY AccountStatusID ORDER BY 2 DESC,1
		SELECT * FROM dbo.Dim_AccountStatus
		SELECT * FROM dbo.Dim_Accounttype

		SELECT TOP 1000 * FROM dbo.Dim_AccountStatusTracker  WHERE CustomerID IN (804854271,6680625) ORDER BY CustomerID DESC, AccountStatusStartDate 
		SELECT TOP 1000 * FROM dbo.Dim_AccountStatusTracker WHERE UserName = 'AccountStatusActor'
		SELECT * FROM dbo.Dim_Channel ORDER BY 1
		*/ 


-- Table swap!
--TableSwap is Not Required, using  Create or Replace Table

--CALL EDW_TRIPS_SUPPORT.TableSwap('EDW_TRIPS.Dim_AccountStatusTracker_NEW', 'EDW_TRIPS.Dim_AccountStatusTracker');

--===============================================================================================================
--:: Load Stage.AccountStatusDetail for dbo.Dim_Customer Load
--===============================================================================================================



CREATE
TEMPORARY TABLE _SESSION.cte_in_progress AS
  (SELECT ast.customerid,
          accountstatusstartdate AS accountcreatedate,
          username AS accountcreatedby,
          ast.channelid AS accountcreatechannelid,
          ch.channelname AS accountcreatechannelname,
          ch.channeldesc AS accountcreatechanneldesc,
          posid AS accountcreateposid
   FROM EDW_TRIPS.Dim_AccountStatusTracker AS ast
   LEFT OUTER JOIN LND_TBOS.TollPlus_Channels AS ch ON ch.channelid = ast.channelid
   WHERE accountstatusid = 16  -- In Progress
     AND rownumfromfirst = 1 );  -- AND ast.CustomerID = 3000000005
  

CREATE
TEMPORARY TABLE _SESSION.cte_firstactive AS
  (SELECT ast.customerid,
          accountstatusstartdate AS accountopendate,
          username AS accountopenedby,
          ast.channelid AS accountopenchannelid,
          ch.channelname AS accountopenchannelname,
          ch.channeldesc AS accountopenchanneldesc,
          posid AS accountopenposid
   FROM EDW_TRIPS.Dim_AccountStatusTracker AS ast
   LEFT OUTER JOIN LND_TBOS.TollPlus_channels AS ch ON ch.channelid = ast.channelid
   WHERE accountstatusid = 17 -- Active
     AND rownumfromfirst = 1  ); -- AND ast.CustomerID = 3000000005
CREATE
TEMPORARY TABLE _SESSION.cte_lastactive AS
  (SELECT ast.customerid,
          accountstatusstartdate AS accountlastactivedate,
          username AS accountlastactiveby,
          ast.channelid AS accountlastactivechannelid,
          ch.channelname AS accountlastactivechannelname,
          ch.channeldesc AS accountlastactivechanneldesc,
          posid AS accountlastactiveposid
   FROM EDW_TRIPS.Dim_AccountStatusTracker AS ast
   LEFT OUTER JOIN LND_TBOS.TollPlus_Channels AS ch ON ch.channelid = ast.channelid
   WHERE accountstatusid = 17 -- Active
     AND rownumfromlast = 1 ); -- AND ast.CustomerID = 3000000005
CREATE
TEMPORARY TABLE _SESSION.cte_lastclose AS
  (SELECT ast.customerid,
          accountstatusstartdate AS accountlastclosedate,
          username AS accountlastcloseby,
          ast.channelid AS accountlastclosechannelid,
          ch.channelname AS accountlastclosechannelname,
          ch.channeldesc AS accountlastclosechanneldesc,
          posid AS accountlastcloseposid
   FROM EDW_TRIPS.Dim_AccountStatusTracker AS ast
   LEFT OUTER JOIN LND_TBOS.TollPlus_Channels AS ch ON ch.channelid = ast.channelid
   WHERE accountstatusid = 20 -- Closed
     AND rownumfromlast = 1  ); -- AND ast.CustomerID = 3000000005

--DROP TABLE IF EXISTS EDW_TRIPS_STAGE.AccountStatusDetail;
CREATE  OR REPLACE TABLE EDW_TRIPS_STAGE.AccountStatusDetail CLUSTER BY CustomerID  AS
SELECT c.customerid,
       c.regcustrefid,
       c.usertypeid,
       CASE
           WHEN p.accountcreatedate IS NULL
                AND fa.accountopendate IS NOT NULL THEN fa.accountopendate
           ELSE coalesce(p.accountcreatedate, c.createddate)
       END AS accountcreatedate,
       CASE
           WHEN p.accountcreatedate IS NULL
                AND fa.accountopendate IS NOT NULL THEN fa.accountopenedby
           ELSE coalesce(p.accountcreatedby, c.createduser)
       END AS accountcreatedby,
       CASE
           WHEN p.accountcreatedate IS NULL
                AND fa.accountopendate IS NOT NULL THEN fa.accountopenchannelid
           ELSE p.accountcreatechannelid
       END AS accountcreatechannelid,
       CASE
           WHEN p.accountcreatedate IS NULL
                AND fa.accountopendate IS NOT NULL THEN fa.accountopenchannelname
           ELSE p.accountcreatechannelname
       END AS accountcreatechannelname,
       CASE
           WHEN p.accountcreatedate IS NULL
                AND fa.accountopendate IS NOT NULL THEN fa.accountopenchanneldesc
           ELSE p.accountcreatechanneldesc
       END AS accountcreatechanneldesc,
       CASE
           WHEN p.accountcreatedate IS NULL
                AND fa.accountopendate IS NOT NULL THEN fa.accountopenposid
           ELSE p.accountcreateposid
       END AS accountcreateposid,
       fa.accountopendate,
       fa.accountopenedby,
       fa.accountopenchannelid,
       fa.accountopenchannelname,
       fa.accountopenchanneldesc,
       fa.accountopenposid,
       la.accountlastactivedate,
       la.accountlastactiveby,
       la.accountlastactivechannelid,
       la.accountlastactivechannelname,
       la.accountlastactivechanneldesc,
       la.accountlastactiveposid,
       lc.accountlastclosedate,
       lc.accountlastcloseby,
       lc.accountlastclosechannelid,
       lc.accountlastclosechannelname,
       lc.accountlastclosechanneldesc,
       lc.accountlastcloseposid
FROM LND_TBOS.TollPlus_TP_Customers AS c
LEFT OUTER JOIN _SESSION.cte_in_progress AS p ON c.customerid = p.customerid
LEFT OUTER JOIN _SESSION.cte_firstactive AS fa ON c.customerid = fa.customerid
LEFT OUTER JOIN _SESSION.cte_lastactive AS la ON c.customerid = la.customerid
LEFT OUTER JOIN _SESSION.cte_lastclose AS lc ON c.customerid = lc.customerid ;


SET log_message = 'Loaded Stage.AccountStatusDetail';

CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, log_message, 'I', -1, CAST(NULL AS STRING));
CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, 'Completed full load', 'I', CAST(NULL AS INT64), CAST(NULL AS STRING));

IF trace_flag = 1 THEN
  SELECT
      'EDW_TRIPS.Dim_AccountStatusTracker' AS tablename,
      *
    FROM
      EDW_TRIPS.dim_accountstatustracker
     ORDER BY
     2 DESC,3
     LIMIT 1000   
  ;
END IF;
IF trace_flag = 1 THEN
  SELECT
      'EDW_TRIPS_STAGE.AccountStatusDetail' AS tablename,
      *
    FROM
      EDW_TRIPS_STAGE.accountstatusdetail
     ORDER BY
     2 DESC
     LIMIT 1000;
END IF;



EXCEPTION WHEN ERROR THEN BEGIN DECLARE error_message STRING DEFAULT @@error.message;

     CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, error_message, 'E', CAST(NULL AS INT64), CAST(NULL AS STRING));
     RAISE USING MESSAGE = error_message; -- ReThrow the error !

END;

END;

/*
--===============================================================================================================
-- DEVELOPER TESTING ZONE to thoroughly test the code for various scenarios
--===============================================================================================================
EXEC dbo.Dim_AccountStatusTracker_Full_Load
SELECT * FROM Utility.ProcessLog WHERE LogSource LIKE '%Dim_AccountStatusTracker%' ORDER BY 1 DESC 
SELECT TOP 100 'dbo.Dim_AccountStatusTracker' Table_Name, * FROM dbo.Dim_AccountStatusTracker ORDER BY 2 DESC, 3
SELECT TOP 100 'Stage.AccountStatusDetail' TableName, * FROM Stage.AccountStatusDetail ORDER BY 2 DESC

--===============================================================================================================
-- USEFUL DATA VALIDATION SCRIPTS for post prod move monitoring or for others to not reinvent the wheel
--===============================================================================================================

--:: INPUT
SELECT TOP 100 'RITE TS History' [RITE TS History], ACCT_STATUS_CODE, *  from EDW_RITE.dbo.ACCOUNT_HISTORY   WHERE ACCT_ID IN (804854271,6680625) ORDER BY ACCT_ID, ACCT_HIST_SEQ;
SELECT TOP 100 'RITE TS Current' [RITE TS Current], ACCT_STATUS_CODE, *  from EDW_RITE.dbo.ACCOUNTS   WHERE ACCT_ID IN (804854271,6680625)  
SELECT TOP 100 'RITE VPS Current' [RITE VPS Current], *  FROM LND_LG_VPS.VP_OWNER.VIOLATORS WHERE VIOLATOR_ID IN (804854271,6680625) 
SELECT TOP 100 'TRIPS History' [TRIPS History], s.AccountStatusDesc, *  from LND_TBOS.History.TP_Customers  c JOIN EDW_TRIPS.dbo.Dim_AccountStatus s ON c.AccountStatusID = s.AccountStatusID WHERE CustomerID IN (804854271,6680625)
SELECT TOP 100 'TRIPS Current' [TRIPS Current], s.AccountStatusDesc, *  from LND_TBOS.TollPlus.TP_Customers c JOIN EDW_TRIPS.dbo.Dim_AccountStatus s ON c.AccountStatusID = s.AccountStatusID  WHERE CustomerID IN (804854271,6680625) ORDER BY c.CustomerID, c.AccountStatusDate
SELECT TOP 100 'TRIPS AccStatus_Tracker' [TRIPS AccStatus_Tracker], s.AccountStatusDesc,*  from LND_TBOS.TollPlus.TP_CUSTOMER_ACCSTATUS_TRACKER c  JOIN EDW_TRIPS.dbo.Dim_AccountStatus s ON c.AccountStatusID = s.AccountStatusID  WHERE CustomerID IN (804854271,6680625)  ORDER BY c.AccStatusHistID

--:: OUTPUT
SELECT TOP 100 'dbo.Dim_AccountStatusTracker' Table_Name, * FROM dbo.Dim_AccountStatusTracker WHERE CustomerID IN (804854271,6680625) ORDER BY 2 DESC, 3
SELECT TOP 100 'Stage.AccountStatusDetail' TableName, * FROM Stage.AccountStatusDetail WHERE CustomerID IN (804854271,6680625) ORDER BY 2 DESC

--:: Quick Data Profiling
SELECT AccountTypeID, AccountTypeDesc, AccountStatusID, AccountStatusDesc, COUNT(1) AccountCount 
FROM dbo.Dim_AccountStatusTracker 
GROUP BY AccountTypeID, AccountTypeDesc, AccountStatusID, AccountStatusDesc 
ORDER BY AccountTypeID, AccountStatusID

*/



END;