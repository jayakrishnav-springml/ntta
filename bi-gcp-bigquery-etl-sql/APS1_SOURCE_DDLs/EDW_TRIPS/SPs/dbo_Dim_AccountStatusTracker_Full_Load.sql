CREATE PROC [dbo].[Dim_AccountStatusTracker_Full_Load] AS

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

BEGIN

	BEGIN TRY

		DECLARE @Log_Source VARCHAR(100) = 'dbo.Dim_AccountStatusTracker_Full_Load', @Log_Start_Date DATETIME2 (3) = SYSDATETIME()
		DECLARE @Log_Message VARCHAR(1000), @Row_Count BIGINT, @Trace_Flag BIT = 0 -- Testing
		EXEC    Utility.ToLog @Log_Source, @Log_Start_Date, 'Started full load', 'I', NULL, NULL

		--===============================================================================================================
		--:: Get Customer Activity from TRIPS (History  + Current)
		--===============================================================================================================

		IF OBJECT_ID('tempdb.dbo.#TRIPS_CustomerHistory') IS NOT NULL DROP TABLE #TRIPS_CustomerHistory;
		SELECT	c.CustomerID, 'TRIPS' DataSource, 'History' TableSource, cs.CustomerStatusDesc, c.UserTypeID AccountTypeID, t.AccountTypeCode, t.AccountTypeDesc, c.AccountStatusID, s.AccountStatusCode, s.AccountStatusDesc, c.AccountStatusDate, c.CreatedDate, c.CreatedUser, C.UpdatedDate, C.UpdatedUser, C.ICNID, C.ChannelID, c.HistID
		INTO	#TRIPS_CustomerHistory 
		FROM	LND_TBOS.History.TP_Customers  c 
		JOIN	dbo.Dim_AccountStatus s ON c.AccountStatusID = s.AccountStatusID
		JOIN	dbo.Dim_AccountType t ON c.UserTypeID = t.AccountTypeID
		JOIN	dbo.Dim_CustomerStatus cs ON c.CustomerStatusID = cs.CustomerStatusID
		UNION																					  
		SELECT	c.CustomerID, 'TRIPS' DataSource, 'Current' TableSource, cs.CustomerStatusDesc, c.UserTypeID AccountTypeID, t.AccountTypeCode, t.AccountTypeDesc, c.AccountStatusID, s.AccountStatusCode, s.AccountStatusDesc, c.AccountStatusDate, c.CreatedDate, c.CreatedUser, C.UpdatedDate, C.UpdatedUser, C.ICNID, C.ChannelID, CAST(NULL AS INT) HistID
		FROM	LND_TBOS.TollPlus.TP_Customers  c 
		JOIN	dbo.Dim_AccountStatus s ON c.AccountStatusID = s.AccountStatusID
		JOIN	dbo.Dim_AccountType t ON c.UserTypeID = t.AccountTypeID
		JOIN	dbo.Dim_CustomerStatus cs ON c.CustomerStatusID = cs.CustomerStatusID
		--ORDER BY CustomerID DESC, AccountStatusDate, UpdatedDate
		
		SET  @Log_Message = 'Loaded #TRIPS_CustomerHistory' 
		EXEC Utility.ToLog @Log_Source, @Log_Start_Date, @Log_Message, 'I', -1, NULL

		/*
		SELECT COUNT(*) [#TRIPS_CustomerHistory] FROM #TRIPS_CustomerHistory 
		SELECT TOP 1000 * FROM #TRIPS_CustomerHistory ORDER BY CustomerID DESC, AccountStatusDate, UpdatedDate
		SELECT * FROM #TRIPS_CustomerHistory WHERE CustomerID = 2010386956 ORDER BY CustomerID DESC, AccountStatusDate, UpdatedDate -- IN (804854271,6680625)
		SELECT AccountStatusID, COUNT(1) [#TRIPS_CustomerHistory Rows] FROM #TRIPS_CustomerHistory GROUP BY AccountStatusID ORDER BY 2 DESC
		SELECT CustomerID, AccountStatusID, CONVERT(DATE, ch.AccountStatusDate), COUNT(1) RC FROM #TRIPS_CustomerHistory ch GROUP BY CustomerID, AccountStatusID, CONVERT(DATE, ch.AccountStatusDate) HAVING COUNT(1) > 1 ORDER BY 1 DESC,2
		*/

		--:: Track activities not found in TP_Customer_AccStatus_Tracker! :-)
		IF OBJECT_ID('tempdb.dbo.#Missing_in_AccStatus_Tracker') IS NOT NULL DROP TABLE #Missing_in_AccStatus_Tracker;
		SELECT DISTINCT CustomerID, AccountStatusID, CONVERT(date,AccountStatusDate) AccountStatusDate INTO #Missing_in_AccStatus_Tracker FROM #TRIPS_CustomerHistory 
		EXCEPT	
		SELECT DISTINCT CustomerID, AccountStatusID, CONVERT(date,AccountStatusDate) AccountStatusDate FROM LND_TBOS.TollPlus.TP_Customer_AccStatus_Tracker 
	
		SET  @Log_Message = 'Loaded #Missing_in_AccStatus_Tracker' 
		EXEC Utility.ToLog @Log_Source, @Log_Start_Date, @Log_Message, 'I', -1, NULL

		/*
		SELECT COUNT(*) [#Missing_in_AccStatus_Tracker] FROM #Missing_in_AccStatus_Tracker 
		SELECT TOP 1000 * FROM #Missing_in_AccStatus_Tracker ORDER BY CustomerID DESC, AccountStatusDate 
		SELECT COUNT(1) [TP_Customer_AccStatus_Tracker] FROM LND_TBOS.TollPlus.TP_Customer_AccStatus_Tracker WHERE CustomerID IN (804854271,6680625) 
		SELECT AccountStatusID, COUNT(1) [TP_Customer_AccStatus_Tracker Rows] FROM LND_TBOS.TollPlus.TP_Customer_AccStatus_Tracker WHERE CustomerID IN (804854271,6680625)  GROUP BY AccountStatusID ORDER BY 2 DESC
		SELECT AccountStatusID, COUNT(1) [#Missing_in_AccStatus_Tracker Rows] FROM #Missing_in_AccStatus_Tracker GROUP BY AccountStatusID ORDER BY 2 DESC
		*/ 

		--:: Get complete picture of Account Status changes done in TRIPS
		IF OBJECT_ID('Stage.TRIPS_AccountStatusTracker') IS NOT NULL DROP TABLE Stage.TRIPS_AccountStatusTracker;
		CREATE TABLE Stage.TRIPS_AccountStatusTracker WITH (CLUSTERED INDEX (CustomerID), DISTRIBUTION = HASH(CustomerID)) AS
		SELECT	s.CustomerID, s.DataSource, s.TableSource, s.CustomerStatusDesc, s.AccountTypeID, s.AccountTypeCode, s.AccountTypeDesc, s.AccountStatusID, s.AccountStatusCode, s.AccountStatusDesc, s.AccountStatusDate, s.CreatedDate, s.CreatedUser, s.UpdatedDate, s.UpdatedUser,
				s.ChannelID, ICN.ICNID, icn.UserID EmployeeID, cc_emp.FirstName + ISNULL( ' ' + CASE WHEN cc_emp.FirstName <> cc_emp.LastName THEN cc_emp.LastName END,'') EmployeeName,  lr.LocationID POSID, s.TRIPS_AccStatusHistID, S.TRIPS_HistID 
		-- SELECT COUNT(1)
		FROM
		(
			SELECT	ast.CustomerID, 'TRIPS' DataSource,  'AccStatusTracker' TableSource, cs.CustomerStatusDesc, c.UserTypeID AccountTypeID, t.AccountTypeCode, t.AccountTypeDesc, ast.AccountStatusID, s.AccountStatusCode, s.AccountStatusDesc, ast.AccountStatusDate, ast.CreatedDate, ast.CreatedUser, ast.UpdatedDate, ast.UpdatedUser, ast.ICNID, ast.ChannelID, ast.AccStatusHistID TRIPS_AccStatusHistID, CAST(NULL AS INT) TRIPS_HistID
			-- SELECT COUNT(1)
			FROM	LND_TBOS.TollPlus.TP_Customer_AccStatus_Tracker  ast
			JOIN	LND_TBOS.TollPlus.TP_Customers c ON c.CustomerID = ast.CustomerID AND ast.LND_UpdateType <> 'D' AND c.LND_UpdateType <> 'D'
			JOIN	dbo.Dim_AccountStatus s ON s.AccountStatusID = ast.AccountStatusID
			JOIN	dbo.Dim_AccountType t ON t.AccountTypeID = c.UserTypeID
			JOIN	dbo.Dim_CustomerStatus cs ON cs.CustomerStatusID = c.CustomerStatusID
			--WHERE	c.CustomerID IN ()
			--ORDER BY CustomerID DESC, AccountStatusDate, UpdatedDate
			UNION
			-- Add the missing activities from Cust History data
			SELECT CustomerID, DataSource, TableSource, CustomerStatusDesc, AccountTypeID, AccountTypeCode, AccountTypeDesc, AccountStatusID, AccountStatusCode, AccountStatusDesc, AccountStatusDate, CreatedDate, CreatedUser, UpdatedDate, UpdatedUser, ICNID, ChannelID, CAST(NULL AS INT) TRIPS_AccStatusHistID, HistID TRIPS_HistID
			--SELECT COUNT(1)
			FROM
			(
				SELECT	ch.DataSource, ch.TableSource, mast.CustomerID, ch.CustomerStatusDesc, ch.AccountTypeID, ch.AccountTypeCode, ch.AccountTypeDesc, ch.AccountStatusID, ch.AccountStatusCode, ch.AccountStatusDesc, ch.AccountStatusDate, ch.CreatedDate, ch.CreatedUser, ch.UpdatedDate, ch.UpdatedUser, ch.ICNID, ch.ChannelID, ISNULL(ch.HistID,999999999) HistID,
						ROW_NUMBER() OVER (PARTITION BY ch.CustomerID, ch.AccountStatusID ORDER BY ch.UpdatedDate DESC, ch.ICNID DESC, ch.ChannelID DESC) RN
				FROM	#Missing_in_AccStatus_Tracker mast
				JOIN	#TRIPS_CustomerHistory ch ON ch.CustomerID = mast.CustomerID AND ch.AccountStatusID = mast.AccountStatusID AND CONVERT(DATE, ch.AccountStatusDate) = mast.AccountStatusDate
			) T 
			WHERE RN = 1	
			--ORDER BY CustomerID DESC, AccountStatusDate, UpdatedDate
		) s
		LEFT JOIN	LND_TBOS.TollPlus.ICN icn ON icn.ICNID = s.ICNID 
		LEFT JOIN	LND_TBOS.RBAC.LocationRoles lr   ON lr.LocationRoleID = icn.LocationRoleID -- has locationid, channelid, icn
		LEFT JOIN	LND_TBOS.TollPlus.TP_Customer_Contacts cc_emp ON cc_emp.CustomerID = icn.USERID AND cc_emp.LND_UpdateType <> 'D'
		--ORDER BY s.CustomerID DESC, s.AccountStatusDate, s.UpdatedDate
		OPTION (LABEL = 'Stage.TRIPS_AccountStatusTracker Load');

		SET  @Log_Message = 'Loaded Stage.TRIPS_AccountStatusTracker' 
		EXEC Utility.ToLog @Log_Source, @Log_Start_Date, @Log_Message, 'I', -1, NULL

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
		IF OBJECT_ID('dbo.Dim_AccountStatusTracker_NEW') IS NOT NULL DROP TABLE dbo.Dim_AccountStatusTracker_NEW
		CREATE TABLE dbo.Dim_AccountStatusTracker_NEW WITH (CLUSTERED INDEX (CustomerID), DISTRIBUTION = HASH(CustomerID)) AS
		SELECT	  AST.CustomerID 
				, ROW_NUMBER() OVER (PARTITION BY AST.CustomerID ORDER BY AST.AccountStatusDate, AST.ICNID DESC, AST.ChannelID DESC) AccountStatusSeq
				, AST.DataSource, AST.TableSource, AST.CustomerStatusDesc, AST.AccountTypeID, AST.AccountTypeDesc, AST.AccountStatusID, AST.AccountStatusDesc
				, AST.AccountStatusDate AccountStatusStartDate, ISNULL(DATEADD(SECOND,-1,LEAD(AST.AccountStatusDate) OVER (PARTITION BY AST.CustomerID ORDER BY AST.AccountStatusDate)),'9999-12-31 23:59:59') AccountStatusEndDate
				, AST.CreatedDate, AST.CreatedUser, AST.UpdatedDate, AST.UpdatedUser
				, AST.EmployeeID, COALESCE(AST.EmployeeName, cc_cust.FirstName + ISNULL( ' ' + CASE WHEN cc_cust.FirstName <> cc_cust.LastName THEN cc_cust.LastName END,''), AST.UpdatedUser) UserName
				, AST.ChannelID, ch.ChannelName, Ch.ChannelDesc
				, AST.POSID, AST.ICNID
				, AST.RITE_Acct_Hist_Seq, AST.TRIPS_AccStatusHistID, AST.TRIPS_HistID
				, ROW_NUMBER() OVER (PARTITION BY AST.CustomerID, AST.AccountStatusID ORDER BY AST.AccountStatusDate, AST.ICNID DESC, AST.ChannelID DESC) RowNumFromFirst
				, ROW_NUMBER() OVER (PARTITION BY AST.CustomerID, AST.AccountStatusID ORDER BY AST.AccountStatusDate DESC, AST.ICNID DESC, AST.ChannelID DESC) RowNumFromLast
				, CAST(SYSDATETIME() AS DATETIME2(3)) EDW_UpdateDate
		FROM 
		(
			SELECT	RST.CustomerID, DataSource, TableSource, cs.CustomerStatusDesc, t.AccountTypeID, t.AccountTypeCode, t.AccountTypeDesc, RST.AccountStatusID, s.AccountStatusCode, s.AccountStatusDesc, RST.AccountStatusDate,RST.CreatedDate, RST.CreatedUser, RST.UpdatedDate, RST.UpdatedUser, CAST(NULL AS BIGINT) ICNID, CAST(NULL AS INT) ChannelID, CAST(NULL AS BIGINT) EmployeeID, CAST (NULL AS VARCHAR(100)) EmployeeName, CAST(NULL AS INT) POSID, RITE_Acct_Hist_Seq, CAST(NULL AS INT) TRIPS_AccStatusHistID, CAST(NULL AS INT) TRIPS_HistID
			FROM	Ref.RITE_AccountStatusHistory RST 
			JOIN	LND_TBOS.TollPlus.TP_Customers c ON c.CustomerID = RST.CustomerID AND c.LND_UpdateType <> 'D'
			JOIN	dbo.Dim_AccountStatus s ON s.AccountStatusID = RST.AccountStatusID
			JOIN	dbo.Dim_AccountType t ON t.AccountTypeID = c.UserTypeID
			JOIN	dbo.Dim_CustomerStatus cs ON cs.CustomerStatusID = c.CustomerStatusID
			WHERE	NOT EXISTS (SELECT 1 FROM Stage.TRIPS_AccountStatusTracker TST WHERE TST.CustomerID = RST.CustomerID AND TST.AccountStatusID = RST.AccountStatusID AND TST.AccountStatusDate = RST.AccountStatusDate AND RST.RITE_HistLast_RN = 1) --ORDER BY RITE_HistLast_RN
			--AND RST.CustomerID IN (804854271,6680625) 
			--ORDER BY CustomerID, AccountStatusDate
			UNION
			SELECT	CustomerID, DataSource, TableSource, CustomerStatusDesc, AccountTypeID, AccountTypeCode, AccountTypeDesc, AccountStatusID, AccountStatusCode, AccountStatusDesc, AccountStatusDate, CreatedDate, CreatedUser, UpdatedDate, UpdatedUser, ICNID, ChannelID, EmployeeID, EmployeeName, POSID,  CAST(NULL AS INT) RITE_Acct_Hist_Seq, TRIPS_AccStatusHistID, TRIPS_HistID
			FROM	Stage.TRIPS_AccountStatusTracker TST 
			--WHERE	TST.CustomerID IN (804854271,6680625) 
			--ORDER BY CustomerID, AccountStatusDate
		) AST
		LEFT JOIN	LND_TBOS.TollPlus.TP_Customer_LogIns cl ON cl.UserName = AST.UpdatedUser
		LEFT JOIN	LND_TBOS.TollPlus.TP_Customer_Contacts cc_cust  ON cc_cust.CustomerID = cl.CustomerID AND cc_cust.LND_UpdateType <> 'D'
		LEFT JOIN	dbo.Dim_Channel AS ch ON ch.ChannelID = AST.ChannelID
		
		--ORDER BY CustomerID, AccountStatusDate
		OPTION (LABEL = 'Dim_AccountStatusTracker_NEW Load');
		
		SET  @Log_Message = 'Loaded Dim_AccountStatusTracker_NEW' 
		EXEC Utility.ToLog @Log_Source, @Log_Start_Date, @Log_Message, 'I', -1, NULL
 
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

		CREATE STATISTICS STATS_dbo_Dim_AccountStatusTracker_NEW_01 ON dbo.Dim_AccountStatusTracker_NEW (AccountStatusID);
		CREATE STATISTICS STATS_dbo_Dim_AccountStatusTracker_NEW_02 ON dbo.Dim_AccountStatusTracker_NEW (AccountStatusStartDate);
		CREATE STATISTICS STATS_dbo_Dim_AccountStatusTracker_NEW_03 ON dbo.Dim_AccountStatusTracker_NEW (AccountStatusEndDate);
		CREATE STATISTICS STATS_dbo_Dim_AccountStatusTracker_NEW_04 ON dbo.Dim_AccountStatusTracker_NEW (ChannelID);
		CREATE STATISTICS STATS_dbo_Dim_AccountStatusTracker_NEW_05 ON dbo.Dim_AccountStatusTracker_NEW (POSID);
		CREATE STATISTICS STATS_dbo_Dim_AccountStatusTracker_NEW_06 ON dbo.Dim_AccountStatusTracker_NEW (AccountStatusDesc);
		CREATE STATISTICS STATS_dbo_Dim_AccountStatusTracker_NEW_07 ON dbo.Dim_AccountStatusTracker_NEW (CreatedDate);
		CREATE STATISTICS STATS_dbo_Dim_AccountStatusTracker_NEW_08 ON dbo.Dim_AccountStatusTracker_NEW (UpdatedDate);
		CREATE STATISTICS STATS_dbo_Dim_AccountStatusTracker_NEW_09 ON dbo.Dim_AccountStatusTracker_NEW (UserName);
		CREATE STATISTICS STATS_dbo_Dim_AccountStatusTracker_NEW_10 ON dbo.Dim_AccountStatusTracker_NEW (ChannelName);
		CREATE STATISTICS STATS_dbo_Dim_AccountStatusTracker_NEW_11 ON dbo.Dim_AccountStatusTracker_NEW (ChannelDesc);
		CREATE STATISTICS STATS_dbo_Dim_AccountStatusTracker_NEW_12 ON dbo.Dim_AccountStatusTracker_NEW (AccountStatusSeq);

		-- Table swap!
		EXEC Utility.TableSwap 'dbo.Dim_AccountStatusTracker_NEW', 'dbo.Dim_AccountStatusTracker'

		--===============================================================================================================
		--:: Load Stage.AccountStatusDetail for dbo.Dim_Customer Load
		--===============================================================================================================

		IF OBJECT_ID('Stage.AccountStatusDetail') IS NOT NULL DROP TABLE Stage.AccountStatusDetail
		CREATE TABLE Stage.AccountStatusDetail WITH (CLUSTERED INDEX (CustomerID), DISTRIBUTION = HASH(CustomerID)) AS
		WITH CTE_In_Progress AS
		(
			SELECT	ast.CustomerID, AccountStatusStartDate AccountCreateDate, UserName AccountCreatedBy, ast.ChannelID AccountCreateChannelID, ch.ChannelName AccountCreateChannelName, ch.ChannelDesc AccountCreateChannelDesc, POSID AccountCreatePOSID
			FROM	dbo.Dim_AccountStatusTracker ast
			LEFT JOIN	LND_TBOS.TollPlus.Channels ch ON ch.ChannelID = ast.ChannelID
			WHERE	AccountStatusID = 16 -- In Progress
					AND RowNumFromFirst = 1
					--AND ast.CustomerID = 3000000005
		)
		, CTE_FirstActive AS
		(
			SELECT ast.CustomerID, AccountStatusStartDate AccountOpenDate, UserName AccountOpenedBy, ast.ChannelID AccountOpenChannelID, ch.ChannelName AccountOpenChannelName, ch.ChannelDesc AccountOpenChannelDesc, POSID AccountOpenPOSID
			FROM	dbo.Dim_AccountStatusTracker ast
			LEFT JOIN	LND_TBOS.TollPlus.Channels ch ON ch.ChannelID = ast.ChannelID
			WHERE	AccountStatusID = 17 -- Active
					AND RowNumFromFirst = 1
					--AND ast.CustomerID = 3000000005
		)
		, CTE_LastActive AS
		(
			SELECT	ast.CustomerID, AccountStatusStartDate AccountLastActiveDate, UserName AccountLastActiveBy, ast.ChannelID AccountLastActiveChannelID, ch.ChannelName AccountLastActiveChannelName, ch.ChannelDesc AccountLastActiveChannelDesc, POSID AccountLastActivePOSID
			FROM	dbo.Dim_AccountStatusTracker ast
			LEFT JOIN	LND_TBOS.TollPlus.Channels ch ON ch.ChannelID = ast.ChannelID
			WHERE	AccountStatusID = 17 -- Active
					AND RowNumFromLast = 1
					--AND ast.CustomerID = 3000000005
		)
		, CTE_LastClose AS
		(
			SELECT	ast.CustomerID, AccountStatusStartDate AccountLastCloseDate, UserName AccountLastCloseBy, ast.ChannelID AccountLastCloseChannelID, ch.ChannelName AccountLastCloseChannelName, ch.ChannelDesc AccountLastCloseChannelDesc, POSID AccountLastClosePOSID
			FROM	dbo.Dim_AccountStatusTracker ast
			LEFT JOIN	LND_TBOS.TollPlus.Channels ch ON ch.ChannelID = ast.ChannelID
			WHERE	AccountStatusID = 20 -- Closed
					AND RowNumFromLast = 1
					--AND ast.CustomerID = 3000000005
		)
		SELECT	c.CustomerID
				, c.RegCustRefID
				, c.UserTypeID
				, CASE WHEN p.AccountCreateDate IS NULL AND fa.AccountOpenDate IS NOT NULL THEN fa.AccountOpenDate ELSE ISNULL(p.AccountCreateDate, C.CreatedDate) END AccountCreateDate
				, CASE WHEN p.AccountCreateDate IS NULL AND fa.AccountOpenDate IS NOT NULL THEN fa.AccountOpenedBy ELSE ISNULL(p.AccountCreatedBy, C.CreatedUser) END AccountCreatedBy
				, CASE WHEN p.AccountCreateDate IS NULL AND fa.AccountOpenDate IS NOT NULL THEN fa.AccountOpenChannelID ELSE p.AccountCreateChannelID END AccountCreateChannelID
				, CASE WHEN p.AccountCreateDate IS NULL AND fa.AccountOpenDate IS NOT NULL THEN fa.AccountOpenChannelName ELSE p.AccountCreateChannelName END AccountCreateChannelName
				, CASE WHEN p.AccountCreateDate IS NULL AND fa.AccountOpenDate IS NOT NULL THEN fa.AccountOpenChannelDesc ELSE p.AccountCreateChannelDesc END AccountCreateChannelDesc
				, CASE WHEN p.AccountCreateDate IS NULL AND fa.AccountOpenDate IS NOT NULL THEN fa.AccountOpenPOSID ELSE p.AccountCreatePOSID END AccountCreatePOSID
				, fa.AccountOpenDate, fa.AccountOpenedBy, fa.AccountOpenChannelID, fa.AccountOpenChannelName, fa.AccountOpenChannelDesc, fa.AccountOpenPOSID
				, la.AccountLastActiveDate, la.AccountLastActiveBy, la.AccountLastActiveChannelID, la.AccountLastActiveChannelName, la.AccountLastActiveChannelDesc, la.AccountLastActivePOSID
				, lc.AccountLastCloseDate, lc.AccountLastCloseBy, lc.AccountLastCloseChannelID, lc.AccountLastCloseChannelName, lc.AccountLastCloseChannelDesc, lc.AccountLastClosePOSID
		FROM	LND_TBOS.TollPlus.TP_Customers c 
		LEFT JOIN CTE_In_Progress  p  ON c.CustomerID = p. CustomerID 
		LEFT JOIN CTE_FirstActive  fa ON c.CustomerID = fa.CustomerID 
		LEFT JOIN CTE_LastActive   la ON c.CustomerID = la.CustomerID
		LEFT JOIN CTE_LastClose    lc ON c.CustomerID = lc.CustomerID
		
		SET  @Log_Message = 'Loaded Stage.AccountStatusDetail' 
		EXEC Utility.ToLog @Log_Source, @Log_Start_Date, @Log_Message, 'I', -1, NULL

		CREATE STATISTICS STATS_Stage_AccountStatusDetail_01 ON Stage.AccountStatusDetail (RegCustRefID);
		CREATE STATISTICS STATS_Stage_AccountStatusDetail_02 ON Stage.AccountStatusDetail (UserTypeID);
		CREATE STATISTICS STATS_Stage_AccountStatusDetail_03 ON Stage.AccountStatusDetail (AccountCreateDate);
		CREATE STATISTICS STATS_Stage_AccountStatusDetail_04 ON Stage.AccountStatusDetail (AccountOpenDate);

		EXEC Utility.ToLog @Log_Source, @Log_Start_Date, 'Completed full load', 'I', NULL, NULL
		
		-- Show results
		IF @Trace_Flag = 1 EXEC Utility.FromLog @Log_Source, @Log_Start_Date
		IF @Trace_Flag = 1 SELECT TOP 1000 'dbo.Dim_AccountStatusTracker' TableName, * FROM dbo.Dim_AccountStatusTracker ORDER BY 2 DESC, 3
		IF @Trace_Flag = 1 SELECT TOP 1000 'Stage.AccountStatusDetail' TableName, * FROM Stage.AccountStatusDetail ORDER BY 2 DESC
	
	END	TRY
	
	BEGIN CATCH
		
		DECLARE @Error_Message VARCHAR(MAX) = ERROR_MESSAGE();
		EXEC    Utility.ToLog @Log_Source, @Log_Start_Date, @Error_Message, 'E', NULL, NULL;
		EXEC	Utility.FromLog @Log_Source, @Log_Start_Date;
		THROW;  -- Rethrow the error!
	
	END CATCH

END

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


