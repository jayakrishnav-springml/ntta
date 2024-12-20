CREATE PROC [Utility].[Fix_TableLoadParameters] AS
/*

USE LND_TBOS 
GO
IF OBJECT_ID ('Utility.[Fix_TableLoadParameters]', 'P') IS NOT NULL DROP PROCEDURE Utility.[Fix_TableLoadParameters]  
GO

###################################################################################################################
Example:
-------------------------------------------------------------------------------------------------------------------
EXEC Utility.[Fix_TableLoadParameters]

===================================================================================================================
Proc Description: 
-------------------------------------------------------------------------------------------------------------------
This proc created to make changes to TableLoadParameters for some tables need to different load from universal version

===================================================================================================================
Change Log:
-------------------------------------------------------------------------------------------------------------------
non	Andy	01/10/2020	New!
###################################################################################################################
*/

---- [EIP].[Transactions]  ----

DECLARE @NewSelectSQL VARCHAR(MAX) = 
'SELECT ISNULL(CAST([Transactions].[TransactionID] AS BIGINT), 0) AS [TransactionID]
	, ISNULL(CAST([Transactions].[AgencyCode] AS VARCHAR(5)), '''') AS [AgencyCode]
	, ISNULL(CAST([Transactions].[ServerID] AS VARCHAR(20)), '''') AS [ServerID]
	, ISNULL(CAST([Transactions].[PlazaID] AS VARCHAR(20)), '''') AS [PlazaID]
	, ISNULL(CAST([Transactions].[LaneID] AS VARCHAR(20)), '''') AS [LaneID]
	, ISNULL(CAST([Transactions].[TranID] AS VARCHAR(20)), '''') AS [TranID]
	, CAST([Transactions].[LanePosition] AS VARCHAR(15)) AS [LanePosition]
	, CAST([Transactions].[IssuingAuthority] AS VARCHAR(15)) AS [IssuingAuthority]
	, CAST(''1900-01-01'' AS DATETIME2(3)) AS LocalTimeStamp	
	, CAST([Transactions].[Timestamp] AS BIGINT) AS [Timestamp]
	, ISNULL(CAST([Transactions].[TransactionDate] AS DATE), ''1900-01-01'') AS [TransactionDate]
	, ISNULL(CAST([Transactions].[TransactionTime] AS INT), 0) AS [TransactionTime]
	, CAST([Transactions].[TransponderID] AS VARCHAR(20)) AS [TransponderID]
	, CAST([Transactions].[TransponderClass] AS VARCHAR(5)) AS [TransponderClass]
	, CAST([Transactions].[VehicleClass] AS VARCHAR(5)) AS [VehicleClass]
	, CAST([Transactions].[Vehiclelength] AS VARCHAR(4)) AS [Vehiclelength]
	, CAST([Transactions].[ViolationCode] AS VARCHAR(4)) AS [ViolationCode]
	, CAST([Transactions].[TollClass] AS INT) AS [TollClass]
	, CAST([Transactions].[TollDue] AS INT) AS [TollDue]
	, CAST([Transactions].[TollPaid] AS INT) AS [TollPaid]
	, ISNULL(CAST([Transactions].[ImageOfRecordID] AS BIGINT), 0) AS [ImageOfRecordID]
	, CAST([Transactions].[PrimaryPlateImageID] AS BIGINT) AS [PrimaryPlateImageID]
	, CAST([Transactions].[PrimaryPlateReadConfidence] AS INT) AS [PrimaryPlateReadConfidence]
	, CAST([Transactions].[OCRPlateRegistration] AS VARCHAR(15)) AS [OCRPlateRegistration]
	, CAST([Transactions].[RegistrationReadConfidence] AS INT) AS [RegistrationReadConfidence]
	, CAST([Transactions].[OCRPlateJurisdiction] AS VARCHAR(8)) AS [OCRPlateJurisdiction]
	, CAST([Transactions].[JurisdictionReadConfidence] AS INT) AS [JurisdictionReadConfidence]
	, CAST([Transactions].[SignatureHandle] AS VARCHAR(15)) AS [SignatureHandle]
	, CAST([Transactions].[SignatureConfidence] AS INT) AS [SignatureConfidence]
	, CAST([Transactions].[CombinedPlateResultStatus] AS SMALLINT) AS [CombinedPlateResultStatus]
	, CAST([Transactions].[CombinedStateResultStatus] AS SMALLINT) AS [CombinedStateResultStatus]
	, ISNULL(CAST([Transactions].[StartDate] AS DATETIME2(0)), ''1900-01-01'') AS [StartDate]
	, CAST([Transactions].[EndDate] AS DATETIME2(0)) AS [EndDate]
	, CAST([Transactions].[StageTypeID] AS INT) AS [StageTypeID]
	, CAST([Transactions].[StageID] AS INT) AS [StageID]
	, CAST([Transactions].[StatusID] AS INT) AS [StatusID]
	, CAST([Transactions].[StatusDescription] AS VARCHAR(256)) AS [StatusDescription]
	, CAST([Transactions].[StatusDate] AS DATETIME2(0)) AS [StatusDate]
	, CAST([Transactions].[VehicleID] AS BIGINT) AS [VehicleID]
	, CAST([Transactions].[GroupID] AS INT) AS [GroupID]
	, ISNULL(CAST([Transactions].[RepresentativeSigImageID] AS BIGINT), 0) AS [RepresentativeSigImageID]
	, ISNULL(CAST([Transactions].[SignatureMatchID] AS BIGINT), 0) AS [SignatureMatchID]
	, ISNULL(CAST([Transactions].[SignatureConflictID1] AS BIGINT), 0) AS [SignatureConflictID1]
	, ISNULL(CAST([Transactions].[SignatureConflictID2] AS BIGINT), 0) AS [SignatureConflictID2]
	, CAST([Transactions].[Daynighttwilight] AS SMALLINT) AS [Daynighttwilight]
	, ISNULL(CAST([Transactions].[Node] AS VARCHAR(15)), '''') AS [Node]
	, ISNULL(CAST([Transactions].[Nodeinst] AS VARCHAR(15)), '''') AS [Nodeinst]
	, ISNULL(CAST([Transactions].[RoadwayID] AS INT), 0) AS [RoadwayID]
	, ISNULL(CAST([Transactions].[AgencyTimestamp] AS BIGINT), 0) AS [AgencyTimestamp]
	, ISNULL(CAST([Transactions].[ReceivedDate] AS DATETIME2(0)), ''1900-01-01'') AS [ReceivedDate]
	, CAST([Transactions].[AuditFileID] AS INT) AS [AuditFileID]
	, CAST([Transactions].[MisreadDisposition] AS INT) AS [MisreadDisposition]
	, CAST([Transactions].[Disposition] AS INT) AS [Disposition]
	, CAST([Transactions].[ReasonCode] AS INT) AS [ReasonCode]
	, CAST([Transactions].[LastReviewer] AS VARCHAR(50)) AS [LastReviewer]
	, CAST([Transactions].[PlateTypePrefix] AS VARCHAR(8)) AS [PlateTypePrefix]
	, CAST([Transactions].[PlateTypeSuffix] AS VARCHAR(8)) AS [PlateTypeSuffix]
	, CAST([Transactions].[PlateRegistration] AS VARCHAR(15)) AS [PlateRegistration]
	, CAST([Transactions].[PlateJurisdiction] AS VARCHAR(8)) AS [PlateJurisdiction]
	, CAST([Transactions].[ISFSerialNumber] AS INT) AS [ISFSerialNumber]
	, CAST([Transactions].[RevenueAxles] AS INT) AS [RevenueAxles]
	, CAST([Transactions].[IndicatedVehicleClass] AS INT) AS [IndicatedVehicleClass]
	, CAST([Transactions].[IndicatedAxles] AS INT) AS [IndicatedAxles]
	, CAST([Transactions].[ActualAxles] AS INT) AS [ActualAxles]
	, CAST([Transactions].[VehicleSpeed] AS INT) AS [VehicleSpeed]
	, CAST([Transactions].[TagStatus] AS SMALLINT) AS [TagStatus]
	, CAST([Transactions].[FacilityCode] AS VARCHAR(45)) AS [FacilityCode]
	, CAST([Transactions].[PlateType] AS VARCHAR(50)) AS [PlateType]
	, CAST([Transactions].[SubscriberID] AS VARCHAR(10)) AS [SubscriberID]
	, ISNULL(CAST([Transactions].[CreatedDate] AS DATETIME2(0)), ''1900-01-01'') AS [CreatedDate]
	, CAST([Transactions].[CreatedUser] AS NVARCHAR(100)) AS [CreatedUser]
	, CAST([Transactions].[UpdatedDate] AS DATETIME2(0)) AS [UpdatedDate]
	, CAST([Transactions].[UpdatedUser] AS NVARCHAR(100)) AS [UpdatedUser]
	, CAST([Transactions].[LND_UpdateDate] AS DATETIME2(3)) AS [LND_UpdateDate]
	, CAST([Transactions].[LND_UpdateType] AS VARCHAR(1)) AS [LND_UpdateType]
FROM [EIP].[Transactions] AS [Transactions]
WHERE 1 = 1'

DECLARE @NewInsertSQL VARCHAR(MAX) = 
'INSERT INTO EIP.Transactions
SELECT ISNULL(CAST([Transactions].[TransactionID] AS BIGINT), 0) AS [TransactionID]
	, ISNULL(CAST([Transactions].[AgencyCode] AS VARCHAR(5)), '''') AS [AgencyCode]
	, ISNULL(CAST([Transactions].[ServerID] AS VARCHAR(20)), '''') AS [ServerID]
	, ISNULL(CAST([Transactions].[PlazaID] AS VARCHAR(20)), '''') AS [PlazaID]
	, ISNULL(CAST([Transactions].[LaneID] AS VARCHAR(20)), '''') AS [LaneID]
	, ISNULL(CAST([Transactions].[TranID] AS VARCHAR(20)), '''') AS [TranID]
	, CAST([Transactions].[LanePosition] AS VARCHAR(15)) AS [LanePosition]
	, CAST([Transactions].[IssuingAuthority] AS VARCHAR(15)) AS [IssuingAuthority]
	, CONVERT (DATETIME2(3),
				DATEADD(HOUR,CASE WHEN [Transactions].TransactionDate BETWEEN tz.DST_Start_Date AND tz.DST_End_Date THEN tz.DST_Offset ELSE tz.Non_DST_Offset END,
						CASE	WHEN LEN([Transactions].TimeStamp) = 10 THEN  DATEADD(SECOND, [Transactions].TimeStamp, ''1970-01-01'')
								WHEN LEN([Transactions].TimeStamp) = 13 THEN DATEADD(MILLISECOND, [Transactions].TimeStamp % 1000, DATEADD(SECOND, [Transactions].TimeStamp / 1000, ''1970-01-01''))
						END		
				)) LocalTimeStamp
	, CAST([Transactions].[Timestamp] AS BIGINT) AS [Timestamp]
	, ISNULL(CAST([Transactions].[TransactionDate] AS DATE), ''1900-01-01'') AS [TransactionDate]
	, ISNULL(CAST([Transactions].[TransactionTime] AS INT), 0) AS [TransactionTime]
	, CAST([Transactions].[TransponderID] AS VARCHAR(20)) AS [TransponderID]
	, CAST([Transactions].[TransponderClass] AS VARCHAR(5)) AS [TransponderClass]
	, CAST([Transactions].[VehicleClass] AS VARCHAR(5)) AS [VehicleClass]
	, CAST([Transactions].[Vehiclelength] AS VARCHAR(4)) AS [Vehiclelength]
	, CAST([Transactions].[ViolationCode] AS VARCHAR(4)) AS [ViolationCode]
	, CAST([Transactions].[TollClass] AS INT) AS [TollClass]
	, CAST([Transactions].[TollDue] AS INT) AS [TollDue]
	, CAST([Transactions].[TollPaid] AS INT) AS [TollPaid]
	, ISNULL(CAST([Transactions].[ImageOfRecordID] AS BIGINT), 0) AS [ImageOfRecordID]
	, CAST([Transactions].[PrimaryPlateImageID] AS BIGINT) AS [PrimaryPlateImageID]
	, CAST([Transactions].[PrimaryPlateReadConfidence] AS INT) AS [PrimaryPlateReadConfidence]
	, CAST([Transactions].[OCRPlateRegistration] AS VARCHAR(15)) AS [OCRPlateRegistration]
	, CAST([Transactions].[RegistrationReadConfidence] AS INT) AS [RegistrationReadConfidence]
	, CAST([Transactions].[OCRPlateJurisdiction] AS VARCHAR(8)) AS [OCRPlateJurisdiction]
	, CAST([Transactions].[JurisdictionReadConfidence] AS INT) AS [JurisdictionReadConfidence]
	, CAST([Transactions].[SignatureHandle] AS VARCHAR(15)) AS [SignatureHandle]
	, CAST([Transactions].[SignatureConfidence] AS INT) AS [SignatureConfidence]
	, CAST([Transactions].[CombinedPlateResultStatus] AS SMALLINT) AS [CombinedPlateResultStatus]
	, CAST([Transactions].[CombinedStateResultStatus] AS SMALLINT) AS [CombinedStateResultStatus]
	, ISNULL(CAST([Transactions].[StartDate] AS DATETIME2(0)), ''1900-01-01'') AS [StartDate]
	, CAST([Transactions].[EndDate] AS DATETIME2(0)) AS [EndDate]
	, CAST([Transactions].[StageTypeID] AS INT) AS [StageTypeID]
	, CAST([Transactions].[StageID] AS INT) AS [StageID]
	, CAST([Transactions].[StatusID] AS INT) AS [StatusID]
	, CAST([Transactions].[StatusDescription] AS VARCHAR(256)) AS [StatusDescription]
	, CAST([Transactions].[StatusDate] AS DATETIME2(0)) AS [StatusDate]
	, CAST([Transactions].[VehicleID] AS BIGINT) AS [VehicleID]
	, CAST([Transactions].[GroupID] AS INT) AS [GroupID]
	, ISNULL(CAST([Transactions].[RepresentativeSigImageID] AS BIGINT), 0) AS [RepresentativeSigImageID]
	, ISNULL(CAST([Transactions].[SignatureMatchID] AS BIGINT), 0) AS [SignatureMatchID]
	, ISNULL(CAST([Transactions].[SignatureConflictID1] AS BIGINT), 0) AS [SignatureConflictID1]
	, ISNULL(CAST([Transactions].[SignatureConflictID2] AS BIGINT), 0) AS [SignatureConflictID2]
	, CAST([Transactions].[Daynighttwilight] AS SMALLINT) AS [Daynighttwilight]
	, ISNULL(CAST([Transactions].[Node] AS VARCHAR(15)), '''') AS [Node]
	, ISNULL(CAST([Transactions].[Nodeinst] AS VARCHAR(15)), '''') AS [Nodeinst]
	, ISNULL(CAST([Transactions].[RoadwayID] AS INT), 0) AS [RoadwayID]
	, ISNULL(CAST([Transactions].[AgencyTimestamp] AS BIGINT), 0) AS [AgencyTimestamp]
	, ISNULL(CAST([Transactions].[ReceivedDate] AS DATETIME2(0)), ''1900-01-01'') AS [ReceivedDate]
	, CAST([Transactions].[AuditFileID] AS INT) AS [AuditFileID]
	, CAST([Transactions].[MisreadDisposition] AS INT) AS [MisreadDisposition]
	, CAST([Transactions].[Disposition] AS INT) AS [Disposition]
	, CAST([Transactions].[ReasonCode] AS INT) AS [ReasonCode]
	, CAST([Transactions].[LastReviewer] AS VARCHAR(50)) AS [LastReviewer]
	, CAST([Transactions].[PlateTypePrefix] AS VARCHAR(8)) AS [PlateTypePrefix]
	, CAST([Transactions].[PlateTypeSuffix] AS VARCHAR(8)) AS [PlateTypeSuffix]
	, CAST([Transactions].[PlateRegistration] AS VARCHAR(15)) AS [PlateRegistration]
	, CAST([Transactions].[PlateJurisdiction] AS VARCHAR(8)) AS [PlateJurisdiction]
	, CAST([Transactions].[ISFSerialNumber] AS INT) AS [ISFSerialNumber]
	, CAST([Transactions].[RevenueAxles] AS INT) AS [RevenueAxles]
	, CAST([Transactions].[IndicatedVehicleClass] AS INT) AS [IndicatedVehicleClass]
	, CAST([Transactions].[IndicatedAxles] AS INT) AS [IndicatedAxles]
	, CAST([Transactions].[ActualAxles] AS INT) AS [ActualAxles]
	, CAST([Transactions].[VehicleSpeed] AS INT) AS [VehicleSpeed]
	, CAST([Transactions].[TagStatus] AS SMALLINT) AS [TagStatus]
	, CAST([Transactions].[FacilityCode] AS VARCHAR(45)) AS [FacilityCode]
	, CAST([Transactions].[PlateType] AS VARCHAR(50)) AS [PlateType]
	, CAST([Transactions].[SubscriberID] AS VARCHAR(10)) AS [SubscriberID]
	, ISNULL(CAST([Transactions].[CreatedDate] AS DATETIME2(0)), ''1900-01-01'') AS [CreatedDate]
	, CAST([Transactions].[CreatedUser] AS NVARCHAR(100)) AS [CreatedUser]
	, CAST([Transactions].[UpdatedDate] AS DATETIME2(0)) AS [UpdatedDate]
	, CAST([Transactions].[UpdatedUser] AS NVARCHAR(100)) AS [UpdatedUser]
	, CAST([Transactions].[LND_UpdateDate] AS DATETIME2(3)) AS [LND_UpdateDate]
	, CAST([Transactions].[LND_UpdateType] AS VARCHAR(1)) AS [LND_UpdateType]
FROM Stage.Transactions AS Transactions
JOIN	Utility.Time_Zone_Offset tz
		ON YEAR(Transactions.TransactionDate) = tz.YYYY
WHERE 1 = 1'

UPDATE Utility.TableLoadParameters
SET SelectSQL = @NewSelectSQL
, InsertSQL = @NewInsertSQL
, UpdateProc = 'EXEC EIP.Transactions_LoadAfterSSIS @Row_Count, @IsFullLoad'
WHERE FullName  = 'EIP.Transactions'


--UPDATE Utility.TableLoadParameters
--SET LoadProcessID = 2
--,UseMultiThreadFlag = 1
--WHERE TableName IN ('ViolatorCollectionsAgencyTracker','VehicleRegBlocks','VehicleImages','TSARawTransactions','TP_Customer_Phones','TP_CustomerTripStatusTracker','ChequePayments','HabitualViolatorStatusTracker')

--UPDATE Utility.TableLoadParameters
--SET LoadProcessID = 3
--,UseMultiThreadFlag = 1
--WHERE TableName IN ('TP_Customer_AccStatus_Tracker','TP_Customer_OutboundCommunications','NTTAHostBOSFileTracker')

--UPDATE Utility.TableLoadParameters
--SET CDCFlag = 1
--WHERE FullName IN ('Finance.Adjustment_LineItems','Finance.Adjustments','IOP.BOS_IOP_OutboundTransactions','Finance.CustomerPayments','Ter.FailureToPayCitations','FInance.GL_Transactions','Finance.Gl_Txn_LineItems','TollPlus.Invoice_Charges_Tracker','TollPlus.Invoice_Header','TollPlus.Invoice_LineItems','TollPlus.Mbsheader','TollPlus.MbsInvoices','TranProcessing.NTTAHostBOSFileTracker','TranProcessing.NTTARawTransactions','Finance.PaymentTxn_LineItems','Finance.PaymentTxns','EIP.Results_Log','TollPlus.TP_Customer_Addresses','TollPlus.TP_Customer_Attributes','TollPlus.TP_Customer_Balances','TollPlus.TP_Customer_Contacts','TollPlus.TP_Customer_Flags','TollPlus.TP_Customer_Internal_Users','TollPlus.TP_Customer_Phones','TollPlus.TP_Customer_Plans','TollPlus.TP_Customer_Tags','TollPlus.TP_Customer_Trip_Charges_Tracker','TollPlus.TP_Customer_Vehicle_Tags','TollPlus.TP_Customer_Vehicles','TollPlus.TP_Customers','TollPlus.TP_CustomerTrips','TollPlus.TP_CustTxns','TollPlus.TP_Image_Review_Result_Images','TollPlus.TP_Image_Review_Results','TollPlus.TP_Invoice_Receipts_Tracker','TollPlus.TP_Trips','TollPlus.TP_Violated_Trip_Charges_Tracker','TollPlus.TP_Violated_Trip_Receipts_Tracker','TollPlus.TP_ViolatedTrips','TollPlus.TpFileTracker','EIP.Transactions','TranProcessing.TSARawTransactions','EIP.VehicleImages','Ter.ViolatorCollectionsInbound','Ter.ViolatorCollectionsOutbound')


/*

There was another possibility to use only new Select query:


'WITH CTE_TimeZone AS
(
	SELECT CAST(2000 AS smallint) AS YYYY, CAST(N''2000-04-02T02:00:00'' AS datetime2(0)) AS DST_Start_Date, CAST(N''2000-10-29T01:59:59.999'' AS datetime2(3)) AS DST_End_Date UNION ALL 
	SELECT CAST(2001 AS smallint) AS YYYY, CAST(N''2001-04-01T02:00:00'' AS datetime2(0)) AS DST_Start_Date, CAST(N''2001-10-28T01:59:59.999'' AS datetime2(3)) AS DST_End_Date UNION ALL 
	SELECT CAST(2002 AS smallint) AS YYYY, CAST(N''2002-04-07T02:00:00'' AS datetime2(0)) AS DST_Start_Date, CAST(N''2002-10-27T01:59:59.999'' AS datetime2(3)) AS DST_End_Date UNION ALL 
	SELECT CAST(2003 AS smallint) AS YYYY, CAST(N''2003-04-06T02:00:00'' AS datetime2(0)) AS DST_Start_Date, CAST(N''2003-10-26T01:59:59.999'' AS datetime2(3)) AS DST_End_Date UNION ALL 
	SELECT CAST(2004 AS smallint) AS YYYY, CAST(N''2004-04-04T02:00:00'' AS datetime2(0)) AS DST_Start_Date, CAST(N''2004-10-31T01:59:59.999'' AS datetime2(3)) AS DST_End_Date UNION ALL 
	SELECT CAST(2005 AS smallint) AS YYYY, CAST(N''2005-04-03T02:00:00'' AS datetime2(0)) AS DST_Start_Date, CAST(N''2005-10-30T01:59:59.999'' AS datetime2(3)) AS DST_End_Date UNION ALL 
	SELECT CAST(2006 AS smallint) AS YYYY, CAST(N''2006-04-02T02:00:00'' AS datetime2(0)) AS DST_Start_Date, CAST(N''2006-10-29T01:59:59.999'' AS datetime2(3)) AS DST_End_Date UNION ALL 
	SELECT CAST(2007 AS smallint) AS YYYY, CAST(N''2007-03-11T02:00:00'' AS datetime2(0)) AS DST_Start_Date, CAST(N''2007-11-04T01:59:59.999'' AS datetime2(3)) AS DST_End_Date UNION ALL 
	SELECT CAST(2008 AS smallint) AS YYYY, CAST(N''2008-03-09T02:00:00'' AS datetime2(0)) AS DST_Start_Date, CAST(N''2008-11-02T01:59:59.999'' AS datetime2(3)) AS DST_End_Date UNION ALL 
	SELECT CAST(2009 AS smallint) AS YYYY, CAST(N''2009-03-08T02:00:00'' AS datetime2(0)) AS DST_Start_Date, CAST(N''2009-11-01T01:59:59.999'' AS datetime2(3)) AS DST_End_Date UNION ALL 
	SELECT CAST(2010 AS smallint) AS YYYY, CAST(N''2010-03-14T02:00:00'' AS datetime2(0)) AS DST_Start_Date, CAST(N''2010-11-07T01:59:59.999'' AS datetime2(3)) AS DST_End_Date UNION ALL 
	SELECT CAST(2011 AS smallint) AS YYYY, CAST(N''2011-03-13T02:00:00'' AS datetime2(0)) AS DST_Start_Date, CAST(N''2011-11-06T01:59:59.999'' AS datetime2(3)) AS DST_End_Date UNION ALL 
	SELECT CAST(2012 AS smallint) AS YYYY, CAST(N''2012-03-11T02:00:00'' AS datetime2(0)) AS DST_Start_Date, CAST(N''2012-11-04T01:59:59.999'' AS datetime2(3)) AS DST_End_Date UNION ALL 
	SELECT CAST(2013 AS smallint) AS YYYY, CAST(N''2013-03-10T02:00:00'' AS datetime2(0)) AS DST_Start_Date, CAST(N''2013-11-03T01:59:59.999'' AS datetime2(3)) AS DST_End_Date UNION ALL 
	SELECT CAST(2014 AS smallint) AS YYYY, CAST(N''2014-03-09T02:00:00'' AS datetime2(0)) AS DST_Start_Date, CAST(N''2014-11-02T01:59:59.999'' AS datetime2(3)) AS DST_End_Date UNION ALL 
	SELECT CAST(2015 AS smallint) AS YYYY, CAST(N''2015-03-08T02:00:00'' AS datetime2(0)) AS DST_Start_Date, CAST(N''2015-11-01T01:59:59.999'' AS datetime2(3)) AS DST_End_Date UNION ALL 
	SELECT CAST(2016 AS smallint) AS YYYY, CAST(N''2016-03-13T02:00:00'' AS datetime2(0)) AS DST_Start_Date, CAST(N''2016-11-06T01:59:59.999'' AS datetime2(3)) AS DST_End_Date UNION ALL 
	SELECT CAST(2017 AS smallint) AS YYYY, CAST(N''2017-03-12T02:00:00'' AS datetime2(0)) AS DST_Start_Date, CAST(N''2017-11-05T01:59:59.999'' AS datetime2(3)) AS DST_End_Date UNION ALL 
	SELECT CAST(2018 AS smallint) AS YYYY, CAST(N''2018-03-11T02:00:00'' AS datetime2(0)) AS DST_Start_Date, CAST(N''2018-11-04T01:59:59.999'' AS datetime2(3)) AS DST_End_Date UNION ALL 
	SELECT CAST(2019 AS smallint) AS YYYY, CAST(N''2019-03-10T02:00:00'' AS datetime2(0)) AS DST_Start_Date, CAST(N''2019-11-03T01:59:59.999'' AS datetime2(3)) AS DST_End_Date UNION ALL 
	SELECT CAST(2020 AS smallint) AS YYYY, CAST(N''2020-03-08T02:00:00'' AS datetime2(0)) AS DST_Start_Date, CAST(N''2020-11-01T01:59:59.999'' AS datetime2(3)) AS DST_End_Date UNION ALL 
	SELECT CAST(2021 AS smallint) AS YYYY, CAST(N''2021-03-14T02:00:00'' AS datetime2(0)) AS DST_Start_Date, CAST(N''2021-11-07T01:59:59.999'' AS datetime2(3)) AS DST_End_Date UNION ALL 
	SELECT CAST(2022 AS smallint) AS YYYY, CAST(N''2022-03-13T02:00:00'' AS datetime2(0)) AS DST_Start_Date, CAST(N''2022-11-06T01:59:59.999'' AS datetime2(3)) AS DST_End_Date UNION ALL 
	SELECT CAST(2023 AS smallint) AS YYYY, CAST(N''2023-03-12T02:00:00'' AS datetime2(0)) AS DST_Start_Date, CAST(N''2023-11-05T01:59:59.999'' AS datetime2(3)) AS DST_End_Date UNION ALL 
	SELECT CAST(2024 AS smallint) AS YYYY, CAST(N''2024-03-10T02:00:00'' AS datetime2(0)) AS DST_Start_Date, CAST(N''2024-11-03T01:59:59.999'' AS datetime2(3)) AS DST_End_Date UNION ALL 
	SELECT CAST(2025 AS smallint) AS YYYY, CAST(N''2025-03-09T02:00:00'' AS datetime2(0)) AS DST_Start_Date, CAST(N''2025-11-02T01:59:59.999'' AS datetime2(3)) AS DST_End_Date 
)
SELECT ISNULL(CAST([Transactions].[TransactionID] AS BIGINT), 0) AS [TransactionID]
	, ISNULL(CAST([Transactions].[AgencyCode] AS VARCHAR(5)), '''') AS [AgencyCode]
	, ISNULL(CAST([Transactions].[ServerID] AS VARCHAR(20)), '''') AS [ServerID]
	, ISNULL(CAST([Transactions].[PlazaID] AS VARCHAR(20)), '''') AS [PlazaID]
	, ISNULL(CAST([Transactions].[LaneID] AS VARCHAR(20)), '''') AS [LaneID]
	, ISNULL(CAST([Transactions].[TranID] AS VARCHAR(20)), '''') AS [TranID]
	, CAST([Transactions].[LanePosition] AS VARCHAR(15)) AS [LanePosition]
	, CAST([Transactions].[IssuingAuthority] AS VARCHAR(15)) AS [IssuingAuthority]
	, CONVERT (DATETIME2(3),
				DATEADD(HOUR,CASE WHEN [Transactions].[TransactionDate] BETWEEN tz.DST_Start_Date AND tz.DST_End_Date THEN -5 ELSE -6 END,
						CASE	WHEN LEN([Transactions].[Timestamp]) = 10 THEN DATEADD(SECOND, [Transactions].[Timestamp], ''1970-01-01'')
								WHEN LEN([Transactions].[Timestamp]) = 13 THEN DATEADD(MILLISECOND, [Transactions].[Timestamp] % 1000, DATEADD(SECOND, [Transactions].[Timestamp] / 1000, ''1970-01-01''))
						END		
				)) LocalTimeStamp
	, CAST([Transactions].[Timestamp] AS BIGINT) AS [Timestamp]
	, ISNULL(CAST([Transactions].[TransactionDate] AS DATE), ''1900-01-01'') AS [TransactionDate]
	, ISNULL(CAST([Transactions].[TransactionTime] AS INT), 0) AS [TransactionTime]
	, CAST([Transactions].[TransponderID] AS VARCHAR(20)) AS [TransponderID]
	, CAST([Transactions].[TransponderClass] AS VARCHAR(5)) AS [TransponderClass]
	, CAST([Transactions].[VehicleClass] AS VARCHAR(5)) AS [VehicleClass]
	, CAST([Transactions].[Vehiclelength] AS VARCHAR(4)) AS [Vehiclelength]
	, CAST([Transactions].[ViolationCode] AS VARCHAR(4)) AS [ViolationCode]
	, CAST([Transactions].[TollClass] AS INT) AS [TollClass]
	, CAST([Transactions].[TollDue] AS INT) AS [TollDue]
	, CAST([Transactions].[TollPaid] AS INT) AS [TollPaid]
	, ISNULL(CAST([Transactions].[ImageOfRecordID] AS BIGINT), 0) AS [ImageOfRecordID]
	, CAST([Transactions].[PrimaryPlateImageID] AS BIGINT) AS [PrimaryPlateImageID]
	, CAST([Transactions].[PrimaryPlateReadConfidence] AS INT) AS [PrimaryPlateReadConfidence]
	, CAST([Transactions].[OCRPlateRegistration] AS VARCHAR(15)) AS [OCRPlateRegistration]
	, CAST([Transactions].[RegistrationReadConfidence] AS INT) AS [RegistrationReadConfidence]
	, CAST([Transactions].[OCRPlateJurisdiction] AS VARCHAR(8)) AS [OCRPlateJurisdiction]
	, CAST([Transactions].[JurisdictionReadConfidence] AS INT) AS [JurisdictionReadConfidence]
	, CAST([Transactions].[SignatureHandle] AS VARCHAR(15)) AS [SignatureHandle]
	, CAST([Transactions].[SignatureConfidence] AS INT) AS [SignatureConfidence]
	, CAST([Transactions].[CombinedPlateResultStatus] AS SMALLINT) AS [CombinedPlateResultStatus]
	, CAST([Transactions].[CombinedStateResultStatus] AS SMALLINT) AS [CombinedStateResultStatus]
	, ISNULL(CAST([Transactions].[StartDate] AS DATETIME2(0)), ''1900-01-01'') AS [StartDate]
	, CAST([Transactions].[EndDate] AS DATETIME2(0)) AS [EndDate]
	, CAST([Transactions].[StageTypeID] AS INT) AS [StageTypeID]
	, CAST([Transactions].[StageID] AS INT) AS [StageID]
	, CAST([Transactions].[StatusID] AS INT) AS [StatusID]
	, CAST([Transactions].[StatusDescription] AS VARCHAR(256)) AS [StatusDescription]
	, CAST([Transactions].[StatusDate] AS DATETIME2(0)) AS [StatusDate]
	, CAST([Transactions].[VehicleID] AS BIGINT) AS [VehicleID]
	, CAST([Transactions].[GroupID] AS INT) AS [GroupID]
	, ISNULL(CAST([Transactions].[RepresentativeSigImageID] AS BIGINT), 0) AS [RepresentativeSigImageID]
	, ISNULL(CAST([Transactions].[SignatureMatchID] AS BIGINT), 0) AS [SignatureMatchID]
	, ISNULL(CAST([Transactions].[SignatureConflictID1] AS BIGINT), 0) AS [SignatureConflictID1]
	, ISNULL(CAST([Transactions].[SignatureConflictID2] AS BIGINT), 0) AS [SignatureConflictID2]
	, CAST([Transactions].[Daynighttwilight] AS SMALLINT) AS [Daynighttwilight]
	, ISNULL(CAST([Transactions].[Node] AS VARCHAR(15)), '''') AS [Node]
	, ISNULL(CAST([Transactions].[Nodeinst] AS VARCHAR(15)), '''') AS [Nodeinst]
	, ISNULL(CAST([Transactions].[RoadwayID] AS INT), 0) AS [RoadwayID]
	, ISNULL(CAST([Transactions].[AgencyTimestamp] AS BIGINT), 0) AS [AgencyTimestamp]
	, ISNULL(CAST([Transactions].[ReceivedDate] AS DATETIME2(0)), ''1900-01-01'') AS [ReceivedDate]
	, CAST([Transactions].[AuditFileID] AS INT) AS [AuditFileID]
	, CAST([Transactions].[MisreadDisposition] AS INT) AS [MisreadDisposition]
	, CAST([Transactions].[Disposition] AS INT) AS [Disposition]
	, CAST([Transactions].[ReasonCode] AS INT) AS [ReasonCode]
	, CAST([Transactions].[LastReviewer] AS VARCHAR(50)) AS [LastReviewer]
	, CAST([Transactions].[PlateTypePrefix] AS VARCHAR(8)) AS [PlateTypePrefix]
	, CAST([Transactions].[PlateTypeSuffix] AS VARCHAR(8)) AS [PlateTypeSuffix]
	, CAST([Transactions].[PlateRegistration] AS VARCHAR(15)) AS [PlateRegistration]
	, CAST([Transactions].[PlateJurisdiction] AS VARCHAR(8)) AS [PlateJurisdiction]
	, CAST([Transactions].[ISFSerialNumber] AS INT) AS [ISFSerialNumber]
	, CAST([Transactions].[RevenueAxles] AS INT) AS [RevenueAxles]
	, CAST([Transactions].[IndicatedVehicleClass] AS INT) AS [IndicatedVehicleClass]
	, CAST([Transactions].[IndicatedAxles] AS INT) AS [IndicatedAxles]
	, CAST([Transactions].[ActualAxles] AS INT) AS [ActualAxles]
	, CAST([Transactions].[VehicleSpeed] AS INT) AS [VehicleSpeed]
	, CAST([Transactions].[TagStatus] AS SMALLINT) AS [TagStatus]
	, CAST([Transactions].[FacilityCode] AS VARCHAR(45)) AS [FacilityCode]
	, CAST([Transactions].[PlateType] AS VARCHAR(50)) AS [PlateType]
	, CAST([Transactions].[SubscriberID] AS VARCHAR(10)) AS [SubscriberID]
	, ISNULL(CAST([Transactions].[CreatedDate] AS DATETIME2(0)), ''1900-01-01'') AS [CreatedDate]
	, CAST([Transactions].[CreatedUser] AS NVARCHAR(100)) AS [CreatedUser]
	, CAST([Transactions].[UpdatedDate] AS DATETIME2(0)) AS [UpdatedDate]
	, CAST([Transactions].[UpdatedUser] AS NVARCHAR(100)) AS [UpdatedUser]
	, CAST([Transactions].[LND_UpdateDate] AS DATETIME2(3)) AS [LND_UpdateDate]
	, CAST([Transactions].[LND_UpdateType] AS VARCHAR(1)) AS [LND_UpdateType]
FROM [EIP].[Transactions] AS [Transactions]
JOIN	CTE_TimeZone tz
		ON YEAR([Transactions].TransactionDate) = tz.YYYY
WHERE 1 = 1'

*/


