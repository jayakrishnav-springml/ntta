CREATE PROC [dbo].[Dim_Customer_Full_Load] AS
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

BEGIN

	BEGIN TRY

		DECLARE @Log_Source VARCHAR(100) = 'dbo.Dim_Customer_Full_Load', @Log_Start_Date DATETIME2 (3) = SYSDATETIME()
		DECLARE @Log_Message VARCHAR(1000), @Row_Count BIGINT, @Trace_Flag BIT = 0 -- Testing
		EXEC    Utility.ToLog @Log_Source, @Log_Start_Date, 'Started full load', 'I', NULL, NULL

		--:: Get Customer Balances
		IF OBJECT_ID('Tempdb..#Customer_Balances') IS NOT NULL DROP TABLE #Customer_Balances;
		CREATE TABLE #Customer_Balances
		WITH (CLUSTERED INDEX (CustomerID ASC), DISTRIBUTION = HASH(CustomerID))
		AS
		SELECT CustomerID, TollBal AS TollTagAcctBalance, VioBal AS ZipCashCustBalance, RefundBal AS RefundBalance, TagDepBal AS TollTagDepositBalance, PostBal AS FleetAcctBalance
		FROM
		(
				SELECT	CustomerID, BalanceType, BalanceAmount
				FROM	LND_TBOS.TollPlus.TP_Customer_Balances 
				WHERE	BalanceType IN ('TollBal','VioBal','RefundBal','TagDepBal','PostBal')
						AND LND_UpdateType <> 'D'
		) AS C
		PIVOT	(	MAX(BalanceAmount)
					FOR BalanceType IN (TollBal,VioBal,RefundBal,TagDepBal, PostBal)
				) AS P	

		SET  @Log_Message = 'Loaded #Customer_Balances' 
		EXEC Utility.ToLog @Log_Source, @Log_Start_Date, @Log_Message, 'I', -1, NULL

		--:: Get Customer Phone numbers
		IF OBJECT_ID('Tempdb..#CustomerPhones') IS NOT NULL DROP TABLE #CustomerPhones;  
		CREATE TABLE #CustomerPhones
		WITH (CLUSTERED INDEX (CustomerID ASC), DISTRIBUTION = HASH(CustomerID))
		AS
		WITH CTE_MobilePhone AS
		(
			SELECT	CustomerID, PhoneType, PhoneNumber AS MobilePhoneNumber, IsCommunication, IsBadPhone,  ROW_NUMBER() OVER (PARTITION BY CustomerID, PhoneType, PhoneNumber ORDER BY IsCommunication DESC) RN_MobileNumber
			FROM	LND_TBOS.TollPlus.TP_Customer_Phones  
			WHERE	IsActive = 1
					AND PhoneType = 'MobileNo'
					AND LND_UpdateType <> 'D'
		),	
		CTE_HomePhone AS
		(
			SELECT	CustomerID, PhoneType, PhoneNumber AS HomePhoneNumber, IsCommunication, IsBadPhone,  ROW_NUMBER() OVER (PARTITION BY CustomerID, PhoneType, PhoneNumber ORDER BY IsCommunication DESC) RN_HomeNumber
			FROM	LND_TBOS.TollPlus.TP_Customer_Phones  
			WHERE	IsActive = 1
					AND PhoneType = 'HomePhone'
					AND LND_UpdateType <> 'D'
		),	
		CTE_WorkPhone AS
		(
			SELECT	CustomerID, PhoneType, PhoneNumber AS WorkPhoneNumber, IsCommunication, IsBadPhone,  ROW_NUMBER() OVER (PARTITION BY CustomerID, PhoneType, PhoneNumber ORDER BY IsCommunication DESC) RN_WorkNumber
			FROM	LND_TBOS.TollPlus.TP_Customer_Phones  
			WHERE	IsActive = 1
					AND PhoneType = 'WorkPhone'
					AND LND_UpdateType <> 'D'
		),
		CTE_CustomerID AS
		(
			SELECT DISTINCT CustomerID FROM LND_TBOS.TollPlus.TP_Customer_Phones WHERE IsActive = 1 AND LND_UpdateType <> 'D' 
		)	
		SELECT	C.CustomerID, MP.MobilePhoneNumber, HP.HomePhoneNumber, WP.WorkPhoneNumber, CAST(CASE WHEN MP.IsCommunication = 1 THEN 'MobilePhone' WHEN HP.IsCommunication = 1 THEN 'HomePhone' WHEN WP.IsCommunication = 1 THEN 'WorkPhone' END AS VARCHAR(15)) PreferredPhoneType
		FROM	CTE_CustomerID C
		LEFT JOIN CTE_MobilePhone MP 
				ON C.CustomerID = MP.CustomerID AND RN_MobileNumber = 1
		LEFT JOIN CTE_HomePhone HP 
				ON C.CustomerID = HP.CustomerID AND RN_HomeNumber = 1
		LEFT JOIN CTE_WorkPhone WP 
				ON C.CustomerID = WP.CustomerID AND RN_WorkNumber = 1

		SET  @Log_Message = 'Loaded #CustomerPhones' 
		EXEC Utility.ToLog @Log_Source, @Log_Start_Date, @Log_Message, 'I', -1, NULL

		--:: Get Customer Flags
		IF OBJECT_ID('Tempdb..#CustomerFlags') IS NOT NULL DROP TABLE #CustomerFlags;
		CREATE TABLE #CustomerFlags
		WITH (CLUSTERED INDEX (CustomerID ASC), DISTRIBUTION = HASH(CustomerID))
		AS 
		SELECT CustomerID, IsBadAddress, IsInCollections, IsHV, IsAdminHearingScheduled, IsPaymentPlanEstablished, IsVRB, IsCitationIssued, IsBankruptcy , IsWriteOff
		FROM
		(
				SELECT	F.CustomerID, L.FlagName, CAST(F.FlagValue AS INT) AS FlagValue
				FROM	LND_TBOS.TollPlus.TP_Customer_Flags F
				JOIN	LND_TBOS.TollPlus.CustomerFlagReferenceLookup L ON L.CustomerFlagReferenceID = F.CustomerFlagReferenceID
				WHERE	L.FlagName IN ('IsBadAddress', 'IsInCollections', 'IsHV', 'IsAdminHearingScheduled', 'IsPaymentPlanEstablished', 'IsVRB', 'IsCitationIssued', 'IsBankruptcy','IsWriteOff')
						AND F.EndDate > GETDATE()
						AND F.LND_UpdateType <> 'D'
		) AS C
		PIVOT	(
					MAX(FlagValue)
					FOR FlagName in (IsBadAddress, IsInCollections, IsHV, IsAdminHearingScheduled, IsPaymentPlanEstablished, IsVRB, IsCitationIssued, IsBankruptcy , IsWriteOff)
				) AS P

		SET  @Log_Message = 'Loaded #CustomerFlags' 
		EXEC Utility.ToLog @Log_Source, @Log_Start_Date, @Log_Message, 'I', -1, NULL

		--:: Get Customer Flags Start Date
		IF OBJECT_ID('Tempdb..#CustomerFlagDates') IS NOT NULL DROP TABLE #CustomerFlagDates;  
		CREATE TABLE #CustomerFlagDates
		WITH (CLUSTERED INDEX (CustomerID ASC), DISTRIBUTION = HASH(CustomerID))
		AS
		WITH CTE_FlagDatesToday AS
		(
			SELECT	F.CustomerID, L.CustomerFlagReferenceID, L.FlagName, F.FlagValue, F.StartDate, F.EndDate, ROW_NUMBER() OVER (PARTITION BY F.CustomerID, L.FlagName ORDER BY  F.StartDate DESC, F.EndDate DESC) RN -- This is to handle duplicate or multiple flag records active as of now
			FROM	LND_TBOS.TollPlus.TP_Customer_Flags F
			JOIN	LND_TBOS.TollPlus.CustomerFlagReferenceLookup L
					ON L.CustomerFlagReferenceID = F.CustomerFlagReferenceID
			WHERE	L.FlagName IN ('IsTollReplenishmentFailed','IsInvalidTollCard')
					AND F.EndDate > GETDATE()
					AND F.LND_UpdateType <> 'D'
		),	
		CTE_CustomerID AS
		(
			SELECT DISTINCT CustomerID FROM CTE_FlagDatesToday
		)	
		SELECT	  C.CustomerID
				, CAST(FD1.FlagValue AS INT) AS AutoRebillFailedFlag, FD1.StartDate AS AutoRebillFailed_StartDate, FD1.EndDate AS AutoRebillFailed_EndDate 
				, CAST(FD2.FlagValue AS INT) AS ExpiredCreditCardFlag, FD2.StartDate AS ExpiredCreditCard_StartDate, FD2.EndDate AS ExpiredCreditCard_EndDate
		FROM	CTE_CustomerID C
		LEFT JOIN CTE_FlagDatesToday FD1 
				ON C.CustomerID = FD1.CustomerID AND FD1.FlagName = 'IsTollReplenishmentFailed' AND FD1.RN = 1
		LEFT JOIN CTE_FlagDatesToday FD2 
				ON C.CustomerID = FD2.CustomerID AND FD2.FlagName = 'IsInvalidTollCard' AND FD2.RN = 1

		SET  @Log_Message = 'Loaded #CustomerFlagDates' 
		EXEC Utility.ToLog @Log_Source, @Log_Start_Date, @Log_Message, 'I', -1, NULL

		IF OBJECT_ID('Tempdb..#Customer_UpdatedDates') IS NOT NULL DROP TABLE #Customer_UpdatedDates;
		CREATE TABLE #Customer_UpdatedDates
		WITH (CLUSTERED INDEX(CustomerID ASC), DISTRIBUTION = HASH(CustomerID))
		AS
		WITH CTE_Customer_UpdatedDates AS
		(
			SELECT 'TP_Customers' TableName, CustomerID, MAX(UpdatedDate) LastUpdatedDate FROM LND_TBOS.TollPlus.TP_Customers WHERE LND_UpdateType <> 'D' GROUP BY CustomerID UNION
			SELECT 'TP_Customer_Attributes' TableName, CustomerID, MAX(UpdatedDate) LastUpdatedDate FROM LND_TBOS.TollPlus.TP_Customer_Attributes WHERE LND_UpdateType <> 'D' GROUP BY CustomerID UNION
			SELECT 'TP_Customer_Contacts' TableName, CustomerID, MAX(UpdatedDate) LastUpdatedDate FROM LND_TBOS.TollPlus.TP_Customer_Contacts WHERE LND_UpdateType <> 'D' GROUP BY CustomerID UNION
			SELECT 'TP_Customer_Addresses' TableName, CustomerID, MAX(UpdatedDate) LastUpdatedDate FROM LND_TBOS.TollPlus.TP_Customer_Addresses WHERE LND_UpdateType <> 'D' GROUP BY CustomerID UNION
			SELECT 'TP_Customer_Plans' TableName, CustomerID, MAX(UpdatedDate) LastUpdatedDate FROM LND_TBOS.TollPlus.TP_Customer_Plans WHERE LND_UpdateType <> 'D' GROUP BY CustomerID UNION
			SELECT 'TP_Customer_Flags' TableName, CustomerID, MAX(UpdatedDate) LastUpdatedDate FROM LND_TBOS.TollPlus.TP_Customer_Flags WHERE LND_UpdateType <> 'D' GROUP BY CustomerID   
		)
		SELECT CustomerID, MAX(LastUpdatedDate) UpdatedDate -- Last UpdatedDate from anyone of these tables for Customer ID
		FROM CTE_Customer_UpdatedDates
		GROUP BY CustomerID

		SET  @Log_Message = 'Loaded #Customer_UpdatedDates' 
		EXEC Utility.ToLog @Log_Source, @Log_Start_Date, @Log_Message, 'I', -1, NULL

		--:: Load dbo.Dim_AccountStatusTracker
		EXEC dbo.Dim_AccountStatusTracker_Full_Load
		SET  @Log_Message = 'Executed dbo.Dim_AccountStatusTracker_Full_Load' 
		EXEC Utility.ToLog @Log_Source, @Log_Start_Date, @Log_Message, 'I', -1, NULL
		
		--:: Get ZC Customer Transition cases. From ZipCash account's viewpoint. NOTE: (1 to 1) -->> 1 Zipcash account = 1 LP. LinkTollTagCustomerID is only one way and is present only on ZC Customer rec, not on TollTag Customer rec.
		IF OBJECT_ID('Tempdb..#ZC_CustTransition') IS NOT NULL DROP TABLE #ZC_CustTransition
		CREATE TABLE #ZC_CustTransition
		WITH (CLUSTERED INDEX (ZipCashCustomerID ASC), DISTRIBUTION = HASH(ZipCashCustomerID))
		AS
		SELECT	ZC.RegCustRefID LinkTollTagCustomerID, TT.AccountCreateDate TollTagAcctCreateDate, ZC.CustomerID AS ZipCashCustomerID, ZC.AccountCreateDate ZipCashAcctCreateDate, CAST(ROW_NUMBER() OVER (PARTITION BY ZC.RegCustRefID ORDER BY ZC.AccountCreateDate ASC) AS SMALLINT) Seq1, CAST(ROW_NUMBER() OVER (PARTITION BY ZC.RegCustRefID ORDER BY ZC.AccountCreateDate DESC) AS SMALLINT) Seq2,
				CAST(CASE WHEN TT.AccountCreateDate > ZC.AccountCreateDate THEN 1 ELSE 0 END AS SMALLINT) ZipCashToTollTagFlag,
				CASE WHEN TT.AccountCreateDate > ZC.AccountCreateDate THEN TT.AccountCreateDate END ZipCashToTollTagDate,
				CAST(CASE WHEN TT.AccountCreateDate < ZC.AccountCreateDate THEN 1 ELSE 0 END AS SMALLINT) TollTagToZipCashFlag,
				CASE WHEN TT.AccountCreateDate < ZC.AccountCreateDate THEN ZC.AccountCreateDate END TollTagToZipCashDate 
		FROM	Stage.AccountStatusDetail ZC
		JOIN	Stage.AccountStatusDetail TT
				ON  TT.CustomerID = ZC.RegCustRefID
		WHERE	ZC.UserTypeID = 11 AND ZC.RegCustRefID > 0 AND TT.AccountOpenDate IS NOT NULL

		SET  @Log_Message = 'Loaded #ZC_CustTransition' 
		EXEC Utility.ToLog @Log_Source, @Log_Start_Date, @Log_Message, 'I', -1, NULL

		--:: Get TT Customer Transition cases. From Tolltag account's viewpoint. NOTE: (1 to many) -->> 1 TollTag account = 1 or more Tag/LP.  
		IF OBJECT_ID('Tempdb..#TT_CustTransition') IS NOT NULL DROP TABLE #TT_CustTransition
		CREATE TABLE #TT_CustTransition
		WITH (CLUSTERED INDEX (LinkTollTagCustomerID ASC), DISTRIBUTION = HASH(LinkTollTagCustomerID))
		AS
		SELECT	ZC_First.LinkTollTagCustomerID, TT.AccountCreateDate TollTagAcctCreateDate,  ZC_First.ZipCashCustomerID FirstZipCashCustomerID, ZC_First.ZipCashAcctCreateDate FirstZipCashAcctCreateDate, ZC_Last.ZipCashCustomerID LastZipCashCustomerID, ZC_Last.ZipCashAcctCreateDate LastZipCashAcctCreateDate, ZC_First.ZipCashAcctCount,
				CAST(CASE WHEN TT.AccountCreateDate > ZC_First.ZipCashAcctCreateDate THEN 1 ELSE 0 END AS SMALLINT)  ZipCashToTollTagFlag,
				CASE WHEN TT.AccountCreateDate > ZC_First.ZipCashAcctCreateDate THEN TT.AccountCreateDate END  ZipCashToTollTagDate,
				CAST(CASE WHEN TT.AccountCreateDate < ZC_Last.ZipCashAcctCreateDate THEN 1 ELSE 0 END AS SMALLINT)  TollTagToZipCashFlag,
				TT_ZC.TollTagToZipCashDate
		FROM	(SELECT LinkTollTagCustomerID, ZipCashCustomerID AS ZipCashCustomerID, ZipCashAcctCreateDate AS ZipCashAcctCreateDate, Seq2 ZipCashAcctCount FROM #ZC_CustTransition T WHERE Seq1 = 1) ZC_First
		JOIN	(SELECT LinkTollTagCustomerID, ZipCashCustomerID AS ZipCashCustomerID, ZipCashAcctCreateDate AS ZipCashAcctCreateDate FROM #ZC_CustTransition T WHERE Seq2 = 1) ZC_Last
				ON ZC_First.LinkTollTagCustomerID = ZC_Last.LinkTollTagCustomerID
		JOIN	(SELECT LinkTollTagCustomerID, MIN(TollTagToZipCashDate) TollTagToZipCashDate FROM #ZC_CustTransition GROUP BY LinkTollTagCustomerID) TT_ZC
				ON TT_ZC.LinkTollTagCustomerID = ZC_First.LinkTollTagCustomerID 
		JOIN	Stage.AccountStatusDetail TT
				ON  TT.CustomerID = ZC_First.LinkTollTagCustomerID

		SET  @Log_Message = 'Loaded #TT_CustTransition' 
		EXEC Utility.ToLog @Log_Source, @Log_Start_Date, @Log_Message, 'I', -1, NULL

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

		--=============================================================================================================
		-- Load dbo.Dim_Customer
		--=============================================================================================================

		IF OBJECT_ID('dbo.Dim_Customer_NEW') IS NOT NULL DROP TABLE dbo.Dim_Customer_NEW
		CREATE TABLE dbo.Dim_Customer_NEW WITH (CLUSTERED INDEX (CustomerID), DISTRIBUTION = HASH(CustomerID)) AS
		SELECT 
			ISNULL(CAST(TP_Customers.CustomerID AS bigint), -1) AS CustomerID
			
			--:: Customer Profile
			, CAST(TP_Customer_Contacts.Title AS varchar(4)) AS Title
			, CAST(TP_Customer_Contacts.FirstName AS varchar(60)) AS FirstName
			, CAST(TP_Customer_Contacts.MiddleName AS varchar(2)) AS MiddleInitial
			, CAST(TP_Customer_Contacts.LastName AS varchar(60)) AS LastName
			, CAST(TP_Customer_Contacts.Suffix AS varchar(5)) AS Suffix
			, ISNULL(CAST(TP_Customer_Addresses.AddressType AS varchar(10)), '') AS AddressType
			, ISNULL(CAST(TP_Customer_Addresses.AddressLine1 AS varchar(150)), '') AS AddressLine1
			, CAST(TP_Customer_Addresses.AddressLine2 AS varchar(50)) AS AddressLine2
			, ISNULL(CAST(TP_Customer_Addresses.City AS varchar(30)), '') AS City
			, ISNULL(CAST(TP_Customer_Addresses.State AS varchar(5)), '') AS State
			, ISNULL(CAST(TP_Customer_Addresses.Country AS varchar(3)), '') AS Country
			, ISNULL(CAST(TP_Customer_Addresses.Zip1 AS varchar(10)), '') AS ZipCode
			, CAST(TP_Customer_Addresses.Zip2 AS varchar(4)) AS Plus4
			, CAST(TP_Customer_Addresses.AddressUpdatedDate AS datetime2(3)) AS AddressUpdatedDate
			
			--:: Customer Phone info
			, CAST(CustomerPhones.MobilePhoneNumber AS varchar(15)) AS MobilePhoneNumber
			, CAST(CustomerPhones.HomePhoneNumber AS varchar(15)) AS HomePhoneNumber
			, CAST(CustomerPhones.WorkPhoneNumber AS varchar(15)) AS WorkPhoneNumber
			, CAST(CustomerPhones.PreferredPhoneType AS varchar(15)) AS PreferredPhoneType

			--:: Customer Plan dimension 
			, ISNULL(CAST(Plans.PlanID AS SMALLINT), -1) AS CustomerPlanID
			, CAST(ISNULL(REPLACE(REPLACE(Plans.PlanName,'Postpaid','Postpaid'),'Prepaid','Prepaid'),'N/A') AS varchar(20)) AS CustomerPlanDesc
			
			--:: AccountCategory dimension
			, CASE  WHEN TP_Customers.UserTypeID in (2,3) AND Plans.PlanName ='Prepaid' THEN 1 -- Ensure this logic is in sync with table code values   
					WHEN TP_Customers.UserTypeID in (2,3) AND Plans.PlanName ='Postpaid' THEN 3
					WHEN TP_Customers.UserTypeID = 11 THEN 2
			  END AS AccountCategoryID
			, CASE  WHEN TP_Customers.UserTypeID in (2,3) AND Plans.PlanName ='Prepaid' THEN 'TagStore'
					WHEN TP_Customers.UserTypeID in (2,3) AND Plans.PlanName ='Postpaid' THEN 'Fleet'
					WHEN TP_Customers.UserTypeID = 11 THEN 'Zipcash'
			  END AS AccountCategoryDesc
			
			--:: AccountType dimension
			, ISNULL(CAST(AccountType.AccountTypeID AS SMALLINT), -1) AS AccountTypeID
			, ISNULL(AccountType.AccountTypeCode, 'Unknown') AS AccountTypeCode
			, ISNULL(AccountType.AccountTypeDesc, 'Unknown') AS AccountTypeDesc

			--:: AccountStatus dimension
			, ISNULL(CAST(AccountStatus.AccountStatusID AS SMALLINT), -1) AS AccountStatusID
			, ISNULL(AccountStatus.AccountStatusCode, 'Unknown') AS AccountStatusCode
			, ISNULL(AccountStatus.AccountStatusDesc, 'Unknown') AS AccountStatusDesc
			, ISNULL(CAST(TP_Customers.AccountStatusDate AS date), '1900-01-01') AS AccountStatusDate
			
			--:: CustomerStatus dimension
			, ISNULL(CustomerStatus.CustomerStatusID, -1) AS CustomerStatusID
			, ISNULL(CustomerStatus.CustomerStatusCode, 'Unknown') AS CustomerStatusCode
			, ISNULL(CustomerStatus.CustomerStatusDesc, 'Unknown') AS CustomerStatusDesc
			
			--:: RevenueCategory dimension
			, ISNULL(CAST(TP_Customers.RevenueCategoryID AS int), 0) AS RevenueCategoryID
			, ISNULL(RevenueCategory.RevenueCategoryCode, 'Unknown') AS RevenueCategoryCode
			, ISNULL(RevenueCategory.RevenueCategoryDesc, 'Unknown') AS RevenueCategoryDesc
			
			--:: RevenueType dimension
			, ISNULL(ISNULL(RevenueType.RevenueTypeID, TP_Customers.RevenueCategoryID), -1) AS RevenueTypeID
			, CAST(ISNULL(ISNULL(RevenueType.RevenueTypeCode, RevenueCategory.RevenueCategoryCode), 'Unknown') AS varchar(50)) AS RevenueTypeCode
			, CAST(ISNULL(ISNULL(RevenueType.RevenueTypeDesc, RevenueCategory.RevenueCategoryDesc), 'Unknown')  AS varchar(100)) AS RevenueTypeDesc
			
			--:: Channel dimension
			, ISNULL(Channel.ChannelID, -1) AS ChannelID
			, ISNULL(Channel.ChannelName, 'Unknown') AS ChannelName
			, ISNULL(Channel.ChannelDesc, 'Unknown') AS ChannelDesc

			--:: Rebill Amount and various Balance type columns
			, ISNULL(CalculatedRebillAmount,0) AS RebillAmount
			, TP_Customer_Attributes.RebillDate AS RebillDate -- !!COLUMN NOT USED IN TRIPS!!
			, ISNULL(AutoReplenishment.AutoReplenishmentID, -1) AS AutoReplenishmentID
			, ISNULL(AutoReplenishment.AutoReplenishmentCode, 'Unknown') AS AutoReplenishmentCode
			, ISNULL(AutoReplenishment.AutoReplenishmentDesc, 'Unknown') AS AutoReplenishmentDesc

			-- TP_Customer_Balances.BalanceDate AS BalanceDate
			, Customer_Balances.TollTagAcctBalance
			, Customer_Balances.ZipCashCustBalance
			, Customer_Balances.RefundBalance
			, Customer_Balances.TollTagDepositBalance
			, Customer_Balances.FleetAcctBalance

			--:: Rental Car / Fleet company info
			, CAST(TP_Customer_Attributes.CompanyCode AS varchar(12)) AS CompanyCode
			, TP_Customer_BusIness.OrganisationName AS CompanyName
			, ISNULL(TP_Customer_BusIness.IsFleet,0) AS FleetFlag

			--:: CustomerFlags
			, ISNULL(CAST(CASE WHEN Plans.PlanName = 'Prepaid' AND CustomerFlags.isBadAddress = 1 AND AccountStatus.AccountStatusDesc <> 'Delinquent' THEN 0 ELSE CustomerFlags.IsBadAddress END AS bit), 0) AS BadAddressFlag -- Updated
			, ISNULL(CAST(CustomerFlags.IsInCollections AS bit), 0) AS InCollectionsFlag
			, ISNULL(CAST(CustomerFlags.IsHV AS bit), 0) AS HVFlag
			, ISNULL(CAST(CustomerFlags.IsAdminHearingScheduled AS bit), 0) AS AdminHearingScheduledFlag
			, ISNULL(CAST(CustomerFlags.IsPaymentPlanEstablished AS bit), 0) AS PaymentPlanEstablishedFlag
			, ISNULL(CAST(CustomerFlags.IsVRB AS bit), 0) AS VRBFlag
			, ISNULL(CAST(CustomerFlags.IsCitationIssued AS bit), 0) AS CitationIssuedFlag
			, ISNULL(CAST(CustomerFlags.IsBankruptcy AS bit), 0) AS BankruptcyFlag
			, ISNULL(CAST(CustomerFlags.IsWriteOff AS bit), 0) AS WriteOffFlag
			, ISNULL(CAST(TP_Customer_Attributes.IsGroundTransportation AS bit), 0) AS GroundTransportationFlag
			, ISNULL(CAST(TP_Customer_Attributes.AutoRecalcReplAmt AS bit), 0) AS AutoRecalcReplAmtFlag
			, ISNULL(CAST(CustomerFlagDates.AutoRebillFailedFlag AS int), -1) AS AutoRebillFailedFlag
			, AutoRebillFailed_StartDate
			, ISNULL(CAST(CustomerFlagDates.ExpiredCreditCardFlag AS int), -1) AS ExpiredCreditCardFlag
			, ExpiredCreditCard_StartDate

			--:: NegBalanceFlag, LowBalanceFlag for TollTag Accounts
			, ISNULL(CAST(CASE WHEN TP_Customers.UserTypeID NOT IN (2,3) /*Toll Tag*/ OR TP_Customers.AccountStatusID IN (16,20) /*In Progress, Closed*/ THEN -1 /*Not Applicable*/
							   WHEN Customer_Balances.TollTagAcctBalance < 0 THEN 1 ELSE 0 END AS SMALLINT),-1) TollTagAcctNegBalanceFlag
			, ISNULL(CAST(CASE WHEN TP_Customers.UserTypeID NOT IN (2,3) /*Toll Tag*/ OR TP_Customers.AccountStatusID IN (16,20) /*In Progress, Closed*/ THEN -1 /*Not Applicable*/
							   WHEN Customer_Balances.TollTagAcctBalance <= ISNULL(TP_Customer_Attributes.ThresholdAmount,0) THEN 1 ELSE 0 END AS SMALLINT),-1) TollTagAcctLowBalanceFlag
			, TP_Customer_Attributes.ThresholdAmount
			, TP_Customer_Balance_Alert_Facts.LowBalanceDate
			, TP_Customer_Balance_Alert_Facts.NegBalanceDate

			--:: ZipCashToTollTag and TollTagToZipCash Transitions. Tip. If RegCustRefID value is present on Zip Cash accounts, they are linked to TollTag account RegCustRefID. Figure out what kind of transition is it! 
			, COALESCE(Link2ZC.LinkTollTagCustomerID,Link2TT.LinkTollTagCustomerID,-1) LinkTollTagCustomerID
			, COALESCE(Link2ZC.ZipCashToTollTagFlag, Link2TT.ZipCashToTollTagFlag, CASE WHEN TP_Customers.UserTypeID IN (2,3) AND Plans.PlanName ='Prepaid' OR TP_Customers.UserTypeID = 11 /*Toll Tag, ZipCash*/ THEN 0 ELSE -1 END) ZipCashToTollTagFlag
			, COALESCE(Link2ZC.ZipCashToTollTagDate,Link2TT.ZipCashToTollTagDate) ZipCashToTollTagDate
			, COALESCE(Link2ZC.TollTagToZipCashFlag, Link2TT.TollTagToZipCashFlag, CASE WHEN TP_Customers.UserTypeID IN (2,3) AND Plans.PlanName ='Prepaid' OR TP_Customers.UserTypeID = 11 /*Toll Tag, ZipCash*/ THEN 0 ELSE -1 END) TollTagToZipCashFlag
			, COALESCE(Link2ZC.TollTagToZipCashDate,Link2TT.TollTagToZipCashDate) TollTagToZipCashDate
			, CASE WHEN TP_Customers.UserTypeID IN (2,3) AND Plans.PlanName ='Prepaid' /*TollTag*/ 
				   THEN CASE WHEN Link2TT.LinkTollTagCustomerID IS NULL OR SD.AccountCreateDate < Link2TT.FirstZipCashAcctCreateDate THEN 1 ELSE 0 END -- Tip. Read < as "before", > as "after"
				   WHEN TP_Customers.UserTypeID = 11 /*ZipCash*/
				   THEN CASE WHEN Link2ZC.LinkTollTagCustomerID IS NULL OR SD.AccountCreateDate < Link2ZC.TollTagAcctCreateDate THEN 1 ELSE 0 END
				   ELSE -1
			  END DirectAcctFlag
		    -- FYI. Validation helper or additional info columns
			, CAST(CASE WHEN TP_Customers.UserTypeID IN (2,3) /*TollTag*/ THEN 0 ELSE Link2ZC.Seq1 END AS SMALLINT) Seq1
			, CAST(CASE WHEN TP_Customers.UserTypeID IN (2,3) /*TollTag*/ THEN 0 ELSE Link2ZC.Seq2 END AS SMALLINT) Seq2
			, Link2ZC.TollTagAcctCreateDate AS ZC_TollTagAcctCreateDate
			, Link2TT.ZipCashAcctCount, Link2TT.FirstZipCashCustomerID, Link2TT.FirstZipCashAcctCreateDate, Link2TT.LastZipCashCustomerID, Link2TT.LastZipCashAcctCreateDate

			--:: Account Status Dates and related attributes
			, SD.AccountCreateDate, SD.AccountCreatedBy, SD.AccountCreateChannelID, SD.AccountCreateChannelName, SD.AccountCreateChannelDesc, SD.AccountCreatePOSID
			, SD.AccountOpenDate, SD.AccountOpenedBy, SD.AccountOpenChannelID, SD.AccountOpenChannelName, SD.AccountOpenChannelDesc, SD.AccountOpenPOSID
			, SD.AccountLastActiveDate, SD.AccountLastActiveBy, SD.AccountLastActiveChannelID, SD.AccountLastActiveChannelName, SD.AccountLastActiveChannelDesc, SD.AccountLastActivePOSID
			, SD.AccountLastCloseDate, SD.AccountLastCloseBy, SD.AccountLastCloseChannelID, SD.AccountLastCloseChannelName, SD.AccountLastCloseChannelDesc, SD.AccountLastClosePOSID

			--:: Misc
			, UD.UpdatedDate AS UpdatedDate
			, CAST(TP_Customers.LND_UpdateDate AS datetime2(3)) AS LND_UpdateDate
			, CAST (SYSDATETIME() AS DATETIME2(3)) AS EDW_UpdateDate

		/*
		SELECT 
			      TP_Customers.CustomerID
			    , CASE  WHEN TP_Customers.UserTypeID in (2,3) AND Plans.PlanName ='Prepaid' THEN 'TagStore'
			    		WHEN TP_Customers.UserTypeID in (2,3) AND Plans.PlanName ='Postpaid' THEN 'Fleet'
			    		WHEN TP_Customers.UserTypeID = 11 THEN 'Zipcash'
			      END AS AccountCategoryDesc
			    , SD.AccountCreateDate
			    , AccountStatus.AccountStatusDesc
			    , AccountStatusDate
			    --:: NegBalanceFlag, LowBalanceFlag for TollTag Accounts
			    , ISNULL(CAST(CASE WHEN AccountTypeID NOT IN (2,3) /*not Toll Tag*/ OR TP_Customers.AccountStatusID IN (16,20) /*In Progress, Closed*/ THEN -1 /*Not Applicable*/
			    				   WHEN Customer_Balances.TollTagAcctBalance < 0 THEN 1 ELSE 0 END AS SMALLINT),-1) TollTagAcctNegBalanceFlag
			    , ISNULL(CAST(CASE WHEN AccountTypeID NOT IN (2,3) /*Toll Tag*/ OR TP_Customers.AccountStatusID IN (16,20) /*In Progress, Closed*/ THEN -1 /*Not Applicable*/
			    				   WHEN Customer_Balances.TollTagAcctBalance <= ISNULL(TP_Customer_Attributes.ThresholdAmount,0) THEN 1 ELSE 0 END AS SMALLINT),-1) TollTagAcctLowBalanceFlag
			    , TP_Customer_Attributes.ThresholdAmount
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
				, COALESCE(Link2ZC.ZipCashToTollTagFlag, Link2TT.ZipCashToTollTagFlag, CASE WHEN TP_Customers.UserTypeID IN (2,3) AND Plans.PlanName ='Prepaid' OR TP_Customers.UserTypeID = 11 /*Toll Tag, ZipCash*/ THEN 0 ELSE -1 END) ZipCashToTollTagFlag
				, COALESCE(Link2ZC.ZipCashToTollTagDate,Link2TT.ZipCashToTollTagDate) ZipCashToTollTagDate
				, COALESCE(Link2ZC.TollTagToZipCashFlag, Link2TT.TollTagToZipCashFlag, CASE WHEN TP_Customers.UserTypeID IN (2,3) AND Plans.PlanName ='Prepaid' OR TP_Customers.UserTypeID = 11 /*Toll Tag, ZipCash*/ THEN 0 ELSE -1 END) TollTagToZipCashFlag
				, COALESCE(Link2ZC.TollTagToZipCashDate,Link2TT.TollTagToZipCashDate) TollTagToZipCashDate
				, CASE WHEN TP_Customers.UserTypeID IN (2,3) AND Plans.PlanName ='Prepaid' /*TollTag*/ 
					   THEN CASE WHEN Link2TT.LinkTollTagCustomerID IS NULL OR SD.AccountCreateDate < Link2TT.FirstZipCashAcctCreateDate THEN 1 ELSE 0 END -- Tip. Read < as "before", > as "after"
					   WHEN TP_Customers.UserTypeID = 11 /*ZipCash*/
					   THEN CASE WHEN Link2ZC.LinkTollTagCustomerID IS NULL OR SD.AccountCreateDate < Link2ZC.TollTagAcctCreateDate THEN 1 ELSE 0 END
					   ELSE -1
				  END DirectAcctFlag
				-- FYI. Validation helper or additional info columns
				, CAST(CASE WHEN TP_Customers.UserTypeID IN (2,3) /*TollTag*/ THEN 0 ELSE Link2ZC.Seq1 END AS SMALLINT) Seq1
				, CAST(CASE WHEN TP_Customers.UserTypeID IN (2,3) /*TollTag*/ THEN 0 ELSE Link2ZC.Seq2 END AS SMALLINT) Seq2
				, Link2ZC.TollTagAcctCreateDate AS ZC_TollTagAcctCreateDate
				, Link2TT.ZipCashAcctCount, Link2TT.FirstZipCashCustomerID, Link2TT.FirstZipCashAcctCreateDate, Link2TT.LastZipCashCustomerID, Link2TT.LastZipCashAcctCreateDate

				--:: Account Status Dates and related attributes
				, SD.AccountCreateDate, SD.AccountCreatedBy, SD.AccountCreateChannelID, SD.AccountCreateChannelName, SD.AccountCreateChannelDesc, SD.AccountCreatePOSID
				, SD.AccountOpenDate, SD.AccountOpenedBy, SD.AccountOpenChannelID, SD.AccountOpenChannelName, SD.AccountOpenChannelDesc, SD.AccountOpenPOSID
				, SD.AccountLastActiveDate, SD.AccountLastActiveBy, SD.AccountLastActiveChannelID, SD.AccountLastActiveChannelName, SD.AccountLastActiveChannelDesc, SD.AccountLastActivePOSID
				, SD.AccountLastCloseDate, SD.AccountLastCloseBy, SD.AccountLastCloseChannelID, SD.AccountLastCloseChannelName, SD.AccountLastCloseChannelDesc, SD.AccountLastClosePOSID
		
		*/

		-- SELECT COUNT(1)
		FROM LND_TBOS.TollPlus.TP_Customers 
		LEFT JOIN LND_TBOS.TollPlus.TP_Customer_Contacts
			 ON TP_Customer_Contacts.CustomerID = TP_Customers.CustomerID 
				AND TP_Customer_Contacts.NameType = 'Primary' 
				AND TP_Customer_Contacts.IsCommunication = 1
				AND TP_Customers.LND_UpdateType <> 'D'
				AND TP_Customer_Contacts.LND_UpdateType <> 'D' 
		LEFT JOIN LND_TBOS.TollPlus.TP_Customer_Addresses 
			 ON TP_Customer_Addresses.CustomerID = TP_Customers.CustomerID 
				-- AND TP_Customer_Addresses.IsValid = 1 -- Show bad address also
				AND TP_Customer_Addresses.IsActive = 1
				AND TP_Customer_Addresses.IsCommunication = 1
				AND TP_Customer_Addresses.LND_UpdateType <> 'D'
		LEFT JOIN LND_TBOS.TollPlus.TP_Customer_Attributes 
			 ON TP_Customer_Attributes.CustomerID = TP_Customers.CustomerID
				AND TP_Customer_Attributes.LND_UpdateType <> 'D'  
		LEFT JOIN LND_TBOS.TollPlus.TP_Customer_Plans 
			 ON TP_Customers.CustomerID = TP_Customer_Plans.CustomerID
				AND TP_Customer_Plans.LND_UpdateType <> 'D' 
		LEFT JOIN LND_TBOS.TollPlus.Plans 
			 ON TP_Customer_Plans.PlanID = Plans.PlanID
				AND Plans.LND_UpdateType <> 'D' 
		LEFT JOIN LND_TBOS.TollPlus.TP_Customer_Business 
			 ON TP_Customers.CustomerID = TP_Customer_Business.CustomerID 
				AND TP_Customer_Business.LND_UpdateType <> 'D' 
		LEFT JOIN dbo.Dim_AccountType AS AccountType
			 ON TP_Customers.UserTypeID = AccountType.AccountTypeID 
		LEFT JOIN dbo.Dim_AccountStatus AS AccountStatus 
			 ON TP_Customers.AccountStatusID = AccountStatus.AccountStatusID
		LEFT JOIN dbo.Dim_CustomerStatus AS CustomerStatus 
			 ON TP_Customers.CustomerStatusID = CustomerStatus.CustomerStatusID
		LEFT JOIN dbo.Dim_RevenueType AS RevenueType	
			ON TP_Customer_Attributes.NonRevenueTypeID = RevenueType.RevenueTypeID
		LEFT JOIN dbo.Dim_RevenueCategory AS RevenueCategory
			ON TP_Customers.RevenueCategoryID = RevenueCategory.RevenueCategoryID
		LEFT JOIN dbo.Dim_Channel AS Channel
			ON TP_Customers.ChannelID = Channel.ChannelID
		LEFT JOIN dbo.Dim_AutoReplenishment AS AutoReplenishment
			ON TP_Customer_Attributes.AutoReplenishmentID = AutoReplenishment.AutoReplenishmentID  
		LEFT JOIN #Customer_Balances AS Customer_Balances
			 ON Customer_Balances.CustomerID = TP_Customers.CustomerID
		LEFT JOIN #CustomerPhones AS CustomerPhones
			 ON CustomerPhones.CustomerID = TP_Customers.CustomerID
		LEFT JOIN #CustomerFlags AS CustomerFlags  
			 ON CustomerFlags.CustomerID = TP_Customers.CustomerID
		LEFT JOIN #CustomerFlagDates AS CustomerFlagDates 
			 ON CustomerFlagDates.CustomerID = TP_Customers.CustomerID
		JOIN #Customer_UpdatedDates UD 
			ON UD.CustomerID = TP_Customers.CustomerID
		LEFT JOIN Stage.AccountStatusDetail SD 
			ON SD.CustomerID = TP_Customers.CustomerID
		LEFT JOIN LND_TBOS.TollPlus.TP_Customer_Balance_Alert_Facts
			 ON TP_Customer_Balance_Alert_Facts.CustomerID = TP_Customers.CustomerID 
		LEFT JOIN #TT_CustTransition Link2TT
			ON Link2TT.LinkTollTagCustomerID = TP_Customers.CustomerID
		LEFT JOIN #ZC_CustTransition Link2ZC 
			ON Link2ZC.ZipCashCustomerID = TP_Customers.CustomerID 
		--WHERE TP_Customers.CustomerID = 137  OR TP_Customers.RegCustRefID = 137
		--ORDER BY COALESCE(Link2ZC.LinkTollTagCustomerID,ZipCashCustomerID, TP_Customers.CustomerID), SD.AccountCreateDate
		OPTION (LABEL = 'dbo.Dim_Customer_NEW Load');

		SET  @Log_Message = 'Loaded dbo.Dim_Customer_NEW' 
		EXEC Utility.ToLog @Log_Source, @Log_Start_Date, @Log_Message, 'I', -1, NULL

		--:: Insert CustomerID -1 row
		INSERT dbo.Dim_Customer_NEW(CustomerID,Title,FirstName,MiddleInitial,LastName,Suffix,AddressType,AddressLine1,AddressLine2,City,State,Country,ZipCode,Plus4,AddressUpdatedDate,MobilePhoneNumber,HomePhoneNumber,WorkPhoneNumber,PreferredPhoneType,CustomerPlanID,CustomerPlanDesc,AccountCategoryID,AccountCategoryDesc,AccountTypeID,AccountTypeCode,AccountTypeDesc,AccountStatusID,AccountStatusCode,AccountStatusDesc,AccountStatusDate,CustomerStatusID,CustomerStatusCode,CustomerStatusDesc,RevenueCategoryID,RevenueCategoryCode,RevenueCategoryDesc,RevenueTypeID,RevenueTypeCode,RevenueTypeDesc,ChannelID,ChannelName,ChannelDesc,RebillAmount,RebillDate,AutoReplenishmentID,AutoReplenishmentCode,AutoReplenishmentDesc,TollTagAcctBalance,ZipCashCustBalance,RefundBalance,TollTagDepositBalance,FleetAcctBalance,CompanyCode,CompanyName,FleetFlag,BadAddressFlag,InCollectionsFlag,HVFlag,AdminHearingScheduledFlag,PaymentPlanEstablishedFlag,VRBFlag,CitationIssuedFlag,BankruptcyFlag,WriteOffFlag,GroundTransportationFlag,AutoRecalcReplAmtFlag,AutoRebillFailedFlag,AutoRebillFailed_StartDate,ExpiredCreditCardFlag,ExpiredCreditCard_StartDate,TollTagAcctNegBalanceFlag,TollTagAcctLowBalanceFlag,ThresholdAmount,LinkTollTagCustomerID,ZipCashToTollTagFlag,ZipCashToTollTagDate,TollTagToZipCashFlag,TollTagToZipCashDate,DirectAcctFlag,ZipCashAcctCount,FirstZipCashAcctCreateDate,LastZipCashAcctCreateDate,AccountCreateDate,AccountCreatedBy,AccountCreateChannelID,AccountCreateChannelName,AccountCreateChannelDesc,AccountCreatePOSID,AccountOpenDate,AccountOpenedBy,AccountOpenChannelID,AccountOpenChannelName,AccountOpenChannelDesc,AccountOpenPOSID,AccountLastActiveDate,AccountLastActiveBy,AccountLastActiveChannelID,AccountLastActiveChannelName,AccountLastActiveChannelDesc,AccountLastActivePOSID,AccountLastCloseDate,AccountLastCloseBy,AccountLastCloseChannelID,AccountLastCloseChannelName,AccountLastCloseChannelDesc,AccountLastClosePOSID,UpdatedDate,LND_UpdateDate,EDW_UpdateDate)
		SELECT -1 AS CustomerID,NULL AS Title,NULL AS FirstName,NULL AS MiddleInitial,NULL AS LastName,NULL AS Suffix,'UNK' AS AddressType,'Unknown' AS AddressLine1,NULL AS AddressLine2,'Unknown' AS City,'UNK' AS State,'UNK' AS Country,'UNK' AS ZipCode,NULL AS Plus4,NULL AS AddressUpdatedDate,NULL AS MobilePhoneNumber,NULL AS HomePhoneNumber,NULL AS WorkPhoneNumber,NULL AS PreferredPhoneType,-1 AS CustomerPlanID,'Unknown' AS CustomerPlanDesc,-1 AS AccountCategoryID,'Unknown' AS AccountCategoryDesc,-1 AS AccountTypeID,'Unknown' AS AccountTypeCode,'Unknown' AS AccountTypeDesc,-1 AS AccountStatusID,'Unknown' AS AccountStatusCode,'Unknown' AS AccountStatusDesc,'1900-01-01' AS AccountStatusDate,-1 AS CustomerStatusID,'Unknown' AS CustomerStatusCode,'Unknown' AS CustomerStatusDesc,-1 AS RevenueCategoryID,'Unknown' AS RevenueCategoryCode,'Unknown' AS RevenueCategoryDesc,-1 AS RevenueTypeID,'Unknown' AS RevenueTypeCode,'Unknown' AS RevenueTypeDesc,-1 AS ChannelID,'Unknown' AS ChannelName,'Unknown' AS ChannelDesc,0 AS RebillAmount,NULL AS RebillDate,-1 AS AutoReplenishmentID,'Unknown' AS AutoReplenishmentCode,'Unknown' AS AutoReplenishmentDesc,NULL AS TollTagAcctBalance,NULL AS ZipCashCustBalance,NULL AS RefundBalance,NULL AS TollTagDepositBalance,NULL AS FleetAcctBalance,NULL AS CompanyCode,NULL AS CompanyName,0 AS FleetFlag,0 AS BadAddressFlag,0 AS InCollectionsFlag,0 AS HVFlag,0 AS AdminHearingScheduledFlag,0 AS PaymentPlanEstablishedFlag,0 AS VRBFlag,0 AS CitationIssuedFlag,0 AS BankruptcyFlag,0 AS WriteOffFlag,0 AS GroundTransportationFlag,0 AS AutoRecalcReplAmtFlag,-1 AS AutoRebillFailedFlag,NULL AS AutoRebillFailed_StartDate,-1 AS ExpiredCreditCardFlag,NULL AS ExpiredCreditCard_StartDate,-1 AS TollTagAcctNegBalanceFlag,-1 AS TollTagAcctLowBalanceFlag,40 AS ThresholdAmount,0 AS LinkTollTagCustomerID,-1 AS ZipCashToTollTagFlag,NULL AS ZipCashToTollTagDate,-1 AS TollTagToZipCashFlag,NULL AS TollTagToZipCashDate,-1 AS DirectAcctFlag,NULL AS ZipCashAcctCount,NULL AS FirstZipCashAcctCreateDate,NULL AS LastZipCashAcctCreateDate,NULL AS AccountCreateDate,NULL AS AccountCreatedBy,NULL AS AccountCreateChannelID,NULL AS AccountCreateChannelName,NULL AS AccountCreateChannelDesc,NULL AS AccountCreatePOSID,NULL AS AccountOpenDate,NULL AS AccountOpenedBy,NULL AS AccountOpenChannelID,NULL AS AccountOpenChannelName,NULL AS AccountOpenChannelDesc,NULL AS AccountOpenPOSID,NULL AS AccountLastActiveDate,NULL AS AccountLastActiveBy,NULL AS AccountLastActiveChannelID,NULL AS AccountLastActiveChannelName,NULL AS AccountLastActiveChannelDesc,NULL AS AccountLastActivePOSID,NULL AS AccountLastCloseDate,NULL AS AccountLastCloseBy,NULL AS AccountLastCloseChannelID,NULL AS AccountLastCloseChannelName,NULL AS AccountLastCloseChannelDesc,NULL AS AccountLastClosePOSID,NULL AS UpdatedDate,NULL AS LND_UpdateDate,SYSDATETIME() AS EDW_UpdateDate

		-- Create statistics
		CREATE STATISTICS STATS_dbo_Dim_Customer_01 ON dbo.Dim_Customer_NEW (CustomerPlanID);
		CREATE STATISTICS STATS_dbo_Dim_Customer_02 ON dbo.Dim_Customer_NEW (AccountTypeID);
		CREATE STATISTICS STATS_dbo_Dim_Customer_03 ON dbo.Dim_Customer_NEW (AccountStatusID);
		CREATE STATISTICS STATS_dbo_Dim_Customer_04 ON dbo.Dim_Customer_NEW (CustomerStatusID);
		CREATE STATISTICS STATS_dbo_Dim_Customer_05 ON dbo.Dim_Customer_NEW (RevenueCategoryID);
		CREATE STATISTICS STATS_dbo_Dim_Customer_06 ON dbo.Dim_Customer_NEW (ChannelID);
		CREATE STATISTICS STATS_dbo_Dim_Customer_07 ON dbo.Dim_Customer_NEW (BadAddressFlag);
		CREATE STATISTICS STATS_dbo_Dim_Customer_08 ON dbo.Dim_Customer_NEW (InCollectionsFlag);
		CREATE STATISTICS STATS_dbo_Dim_Customer_09 ON dbo.Dim_Customer_NEW (HVFlag);
		CREATE STATISTICS STATS_dbo_Dim_Customer_10 ON dbo.Dim_Customer_NEW (AdminHearingScheduledFlag);
		CREATE STATISTICS STATS_dbo_Dim_Customer_11 ON dbo.Dim_Customer_NEW (PaymentPlanEstablishedFlag);
		CREATE STATISTICS STATS_dbo_Dim_Customer_12 ON dbo.Dim_Customer_NEW (VRBFlag);
		CREATE STATISTICS STATS_dbo_Dim_Customer_13 ON dbo.Dim_Customer_NEW (CitationIssuedFlag);
		CREATE STATISTICS STATS_dbo_Dim_Customer_14 ON dbo.Dim_Customer_NEW (BankruptcyFlag);
		CREATE STATISTICS STATS_dbo_Dim_Customer_15 ON dbo.Dim_Customer_NEW (WriteOffFlag);
		CREATE STATISTICS STATS_dbo_Dim_Customer_16 ON dbo.Dim_Customer_NEW (GroundTransportationFlag);
		CREATE STATISTICS STATS_dbo_Dim_Customer_17 ON dbo.Dim_Customer_NEW (AutoRecalcReplAmtFlag);
		CREATE STATISTICS STATS_dbo_Dim_Customer_18 ON dbo.Dim_Customer_NEW (AccountCreateDate);
		CREATE STATISTICS STATS_dbo_Dim_Customer_19 ON dbo.Dim_Customer_NEW (AccountOpenDate);
		CREATE STATISTICS STATS_dbo_Dim_Customer_20 ON dbo.Dim_Customer_NEW (AccountLastActiveDate);
		CREATE STATISTICS STATS_dbo_Dim_Customer_21 ON dbo.Dim_Customer_NEW (AccountLastCloseDate);
		CREATE STATISTICS STATS_dbo_Dim_Customer_22 ON dbo.Dim_Customer_NEW (AccountCreatedBy);
		CREATE STATISTICS STATS_dbo_Dim_Customer_23 ON dbo.Dim_Customer_NEW (AccountOpenedBy);
		CREATE STATISTICS STATS_dbo_Dim_Customer_24 ON dbo.Dim_Customer_NEW (AccountLastActiveBy);
		CREATE STATISTICS STATS_dbo_Dim_Customer_25 ON dbo.Dim_Customer_NEW (AccountLastCloseBy);
		CREATE STATISTICS STATS_dbo_Dim_Customer_26 ON dbo.Dim_Customer_NEW (AccountCreateChannelID);
		CREATE STATISTICS STATS_dbo_Dim_Customer_27 ON dbo.Dim_Customer_NEW (AccountOpenChannelID);
		CREATE STATISTICS STATS_dbo_Dim_Customer_28 ON dbo.Dim_Customer_NEW (AccountLastActiveChannelID);
		CREATE STATISTICS STATS_dbo_Dim_Customer_29 ON dbo.Dim_Customer_NEW (AccountLastCloseChannelID);
		CREATE STATISTICS STATS_dbo_Dim_Customer_30 ON dbo.Dim_Customer_NEW (AccountCreateChannelName);
		CREATE STATISTICS STATS_dbo_Dim_Customer_31 ON dbo.Dim_Customer_NEW (AccountOpenChannelName);
		CREATE STATISTICS STATS_dbo_Dim_Customer_32 ON dbo.Dim_Customer_NEW (AccountLastActiveChannelName);
		CREATE STATISTICS STATS_dbo_Dim_Customer_33 ON dbo.Dim_Customer_NEW (AccountLastCloseChannelName);
		CREATE STATISTICS STATS_dbo_Dim_Customer_34 ON dbo.Dim_Customer_NEW (AccountCreatePOSID);
		CREATE STATISTICS STATS_dbo_Dim_Customer_35 ON dbo.Dim_Customer_NEW (AccountOpenPOSID);
		CREATE STATISTICS STATS_dbo_Dim_Customer_36 ON dbo.Dim_Customer_NEW (AccountLastActivePOSID);
		CREATE STATISTICS STATS_dbo_Dim_Customer_37 ON dbo.Dim_Customer_NEW (AccountLastClosePOSID);
		CREATE STATISTICS STATS_dbo_Dim_Customer_38 ON dbo.Dim_Customer_NEW (AutoReplenishmentCode);
		CREATE STATISTICS STATS_dbo_Dim_Customer_39 ON dbo.Dim_Customer_NEW (AutoReplenishmentDesc);
		CREATE STATISTICS STATS_dbo_Dim_Customer_40 ON dbo.Dim_Customer_NEW (AccountCategoryDesc);
		CREATE STATISTICS STATS_dbo_Dim_Customer_41 ON dbo.Dim_Customer_NEW (TollTagAcctNegBalanceFlag);
		CREATE STATISTICS STATS_dbo_Dim_Customer_42 ON dbo.Dim_Customer_NEW (TollTagAcctLowBalanceFlag);
		CREATE STATISTICS STATS_dbo_Dim_Customer_43 ON dbo.Dim_Customer_NEW (LinkTollTagCustomerID);
		CREATE STATISTICS STATS_dbo_Dim_Customer_44 ON dbo.Dim_Customer_NEW (ZipCashToTollTagFlag);
		CREATE STATISTICS STATS_dbo_Dim_Customer_45 ON dbo.Dim_Customer_NEW (ZipCashToTollTagDate);
		CREATE STATISTICS STATS_dbo_Dim_Customer_46 ON dbo.Dim_Customer_NEW (TollTagToZipCashFlag);
		CREATE STATISTICS STATS_dbo_Dim_Customer_47 ON dbo.Dim_Customer_NEW (TollTagToZipCashDate);
		CREATE STATISTICS STATS_dbo_Dim_Customer_48 ON dbo.Dim_Customer_NEW (DirectAcctFlag);
		CREATE STATISTICS STATS_dbo_Dim_Customer_49 ON dbo.Dim_Customer_NEW (AutoRebillFailedFlag);
		CREATE STATISTICS STATS_dbo_Dim_Customer_50 ON dbo.Dim_Customer_NEW (ExpiredCreditCardFlag);
		CREATE STATISTICS STATS_dbo_Dim_Customer_51 ON dbo.Dim_Customer_NEW (AutoRebillFailed_StartDate);
		CREATE STATISTICS STATS_dbo_Dim_Customer_52 ON dbo.Dim_Customer_NEW (ExpiredCreditCard_StartDate);
		CREATE STATISTICS STATS_dbo_Dim_Customer_53 ON dbo.Dim_Customer_NEW (MobilePhoneNumber);
		CREATE STATISTICS STATS_dbo_Dim_Customer_54 ON dbo.Dim_Customer_NEW (HomePhoneNumber);
		CREATE STATISTICS STATS_dbo_Dim_Customer_55 ON dbo.Dim_Customer_NEW (WorkPhoneNumber);
		CREATE STATISTICS STATS_dbo_Dim_Customer_56 ON dbo.Dim_Customer_NEW (PreferredPhoneType);

		-- Table swap!
		EXEC Utility.TableSwap 'dbo.Dim_Customer_NEW', 'dbo.Dim_Customer'

		EXEC Utility.ToLog @Log_Source, @Log_Start_Date, 'Completed full load', 'I', NULL, NULL
		
		-- Show results
		IF @Trace_Flag = 1 EXEC Utility.FromLog @Log_Source, @Log_Start_Date
		IF @Trace_Flag = 1 SELECT TOP 1000 'dbo.Dim_Customer' TableName, * FROM dbo.Dim_Customer ORDER BY 2 DESC
	
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



