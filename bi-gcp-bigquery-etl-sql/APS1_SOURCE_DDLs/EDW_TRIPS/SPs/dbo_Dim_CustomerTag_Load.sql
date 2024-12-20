CREATE PROC [dbo].[Dim_CustomerTag_Load] @IsFullLoad [BIT] AS
/*
IF OBJECT_ID ('dbo.Dim_CustomerTag_Load', 'P') IS NOT NULL DROP PROCEDURE dbo.Dim_CustomerTag_Load
GO
###################################################################################################################
Proc Description: 
-------------------------------------------------------------------------------------------------------------------
Load dbo.Dim_CustomerTag table. 

@IsFullLoad - 1 means forced Full load, 0 or NULL - incremental load. If the main table doesn't exists - It goes with full load.

===================================================================================================================
Change Log:
-------------------------------------------------------------------------------------------------------------------
CHG0038319 	Andy		2021-03-08	New!
CHG0039156  Sagarika    2021-06-24  Rename TagSpeciality as SpecialityTag, IsNonRevenue to NonRevenueFlag to avoid failure in Utility.UpdateTableWithTable for Incremental Loads and 
                                    Titlecase the TagStatus column values which are causing duplicate issue in Microstrategy Reports ( Eg: Assigned, ASSIGNED)		

###################################################################################################################
*/

BEGIN

	/*====================================== TESTING =======================================================================*/
	--DECLARE @IsFullLoad BIT = 1 
	/*====================================== TESTING =======================================================================*/

	DECLARE @Log_Source VARCHAR(100) = 'dbo.Dim_CustomerTag_Load', @TableName VARCHAR(50) = 'dbo.Dim_CustomerTag', @StageTableName VARCHAR(100) = 'dbo.Dim_CustomerTag_NEW'
	DECLARE @Log_Start_Date DATETIME2(3) = SYSDATETIME(), @Log_Message VARCHAR(1000), @Trace_Flag BIT = 0 -- Testing
	DECLARE @Last_CustomerTags_Date DATETIME2(3), @IdentifyingColumns VARCHAR(100) = '[CustTagID]' 
	DECLARE @sql VARCHAR(MAX)--, @WhereSql VARCHAR(8000) = ''

	IF OBJECT_ID(@TableName) IS NULL
		SET @IsFullLoad = 1

	IF @IsFullLoad = 1
	BEGIN
		SET @Log_Message = 'Started Full load'
		IF @Trace_Flag = 1 PRINT @Log_Message
		EXEC Utility.ToLog @Log_Source, @Log_Start_Date, @Log_Message, 'I', NULL, NULL

		IF OBJECT_ID('dbo.Dim_CustomerTag_NEW','U') IS NOT NULL			DROP TABLE dbo.Dim_CustomerTag_NEW;
		CREATE TABLE dbo.Dim_CustomerTag_NEW WITH (CLUSTERED INDEX (CustTagID),  DISTRIBUTION = HASH(CustomerID)) AS
		--EXPLAIN
		SELECT 
			  ISNULL(CAST(TP_Customer_Tags.CustTagID AS bigint), 0) AS CustTagID
			, ISNULL(CAST(TP_Customer_Tags.CustomerID AS bigint), -1) AS CustomerID
			, ISNULL(CAST(TP_Customer_Tags.SerialNo AS varchar(12)), '-1') AS TagID
			, ISNULL(CAST(TP_Customer_Tags.ChannelID AS int), -1) AS ChannelID
			, CAST(TP_Customer_Tags.TagAgency AS varchar(6)) AS TagAgency
			, ISNULL(CAST(TP_Customer_Tags.TagType AS varchar(20)), '') AS TagType
            , ISNULL(CAST(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(LEFT(Upper(TagStatus), 1) + SUBSTRING(LOWER(TagStatus), 2, LEN(TagStatus)),
              'Received','Received'),'Replacement','Replacement'),'Damaged','Damaged'),'Defective','Defective'),'Inactive','Inactive')
              AS VARCHAR(20) ), '') AS TagStatus
            , ISNULL(CAST(TP_Customer_Tags.TagStartDate AS date), '1900-01-01') AS TagStatusStartDate
			, ISNULL(CAST(TP_Customer_Tags.TagEndDate AS date), '9999-12-31') AS TagStatusEndDate
			, ISNULL(CAST(TP_Customer_Tags.TagAssignedDate AS date), '1900-01-01') AS TagAssignedDate
			, ISNULL(CAST(TP_Customer_Tags.TagAssignedEndDate AS date), '9999-12-31') AS TagAssignedEndDate
            , CAST(TP_Customer_Tags.ItemCode AS varchar(20)) AS ItemCode
			, CAST(TP_Customer_Tags.Mounting AS varchar(20)) AS Mounting
			, CAST(TP_Customer_Tags.SpecialityTag AS varchar(30)) AS SpecialityTag
			, ISNULL(CAST(TP_Customer_Tags.IsNonRevenue AS bit), 0) AS NonRevenueFlag
			, ISNULL(CAST(TP_Customer_Tags.UpdatedDate AS datetime2(3)), '1900-01-01') AS UpdatedDate
			, ISNULL(CAST(TP_Customer_Tags.LND_UpdateDate AS datetime2(3)), '1900-01-01') AS LND_UpdateDate
			, ISNULL(@Log_Start_Date, '1900-01-01') AS EDW_UpdateDate
		FROM LND_TBOS.TollPlus.TP_Customer_Tags
		UNION ALL
		SELECT
			-1 AS CustTagID, -1 AS CustomerID, '-1' AS TagID, -1 AS ChannelID, 
			 '' AS TagAgency, '' AS TagType, '' AS TagStatus, 
			'1900-01-01' AS TagStatusStartDate, '9999-12-31' AS TagStatusEndDate,
			'1900-01-01' AS TagAssignedDate, '9999-12-31' AS TagAssignedEndDate,
			 '' AS ItemCode, '' AS Mounting, '' AS SpecialityTag, 0 AS NonRevenueFlag, 
			'1900-01-01' AS UpdatedDate, '1900-01-01' AS LND_UpdateDate, @Log_Start_Date AS EDW_UpdateDate
		OPTION (LABEL = 'dbo.Dim_CustomerTag_NEW');

		SET  @Log_Message = 'Loaded ' + @StageTableName
		EXEC Utility.FastLog @Log_Source, @Log_Message, -1

		CREATE STATISTICS Stats_dbo_Dim_CustomerTag_001 ON dbo.Dim_CustomerTag_NEW (CustomerID);
		CREATE STATISTICS STATS_dbo_Dim_CustomerTag_002 ON dbo.Dim_CustomerTag_NEW (TagID,TagAgency);
		CREATE STATISTICS STATS_dbo_Dim_CustomerTag_003 ON dbo.Dim_CustomerTag_NEW (TagAgency);
		CREATE STATISTICS STATS_dbo_Dim_CustomerTag_004 ON dbo.Dim_CustomerTag_NEW (TagType);
		CREATE STATISTICS STATS_dbo_Dim_CustomerTag_005 ON dbo.Dim_CustomerTag_NEW (TagStatus);
		CREATE STATISTICS STATS_dbo_Dim_CustomerTag_006 ON dbo.Dim_CustomerTag_NEW (TagStatusStartDate, TagStatusEndDate);

		-- Table swap!
		EXEC Utility.TableSwap @StageTableName, @TableName

		SET @Log_Message = 'Completed Full load'

	END
	ELSE
	BEGIN
		EXEC Utility.Get_UpdatedDate @TableName, @Last_CustomerTags_Date OUTPUT 
		SET @Log_Message = 'Started Incremental load from: ' + CONVERT(VARCHAR(25),@Last_CustomerTags_Date,121)

		IF @Trace_Flag = 1 PRINT @Log_Message
		EXEC Utility.ToLog @Log_Source, @Log_Start_Date, @Log_Message, 'I', NULL, NULL

		IF OBJECT_ID('dbo.Dim_CustomerTag_NEW','U') IS NOT NULL			DROP TABLE dbo.Dim_CustomerTag_NEW;
		CREATE TABLE dbo.Dim_CustomerTag_NEW WITH (CLUSTERED INDEX (CustTagID),  DISTRIBUTION = HASH(CustomerID)) AS
		--EXPLAIN
		SELECT 
			  ISNULL(CAST(TP_Customer_Tags.CustTagID AS bigint), 0) AS CustTagID
			, ISNULL(CAST(TP_Customer_Tags.CustomerID AS bigint), -1) AS CustomerID
			, ISNULL(CAST(TP_Customer_Tags.SerialNo AS varchar(12)), '-1') AS TagID
			, ISNULL(CAST(TP_Customer_Tags.ChannelID AS int), -1) AS ChannelID
			, CAST(TP_Customer_Tags.TagAgency AS varchar(6)) AS TagAgency
			, ISNULL(CAST(TP_Customer_Tags.TagType AS varchar(20)), '') AS TagType
            , ISNULL(CAST(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(LEFT(Upper(TagStatus), 1) + SUBSTRING(LOWER(TagStatus), 2, LEN(TagStatus)),
              'Received','Received'),'Replacement','Replacement'),'Damaged','Damaged'),'Defective','Defective'),'Inactive','Inactive')
              AS VARCHAR(20) ), '') AS TagStatus			
            , ISNULL(CAST(TP_Customer_Tags.TagStartDate AS date), '1900-01-01') AS TagStatusStartDate
			, ISNULL(CAST(TP_Customer_Tags.TagEndDate AS date), '9999-12-31') AS TagStatusEndDate
			, ISNULL(CAST(TP_Customer_Tags.TagAssignedDate AS date), '1900-01-01') AS TagAssignedDate
			, ISNULL(CAST(TP_Customer_Tags.TagAssignedEndDate AS date), '9999-12-31') AS TagAssignedEndDate
			, CAST(TP_Customer_Tags.ItemCode AS varchar(20)) AS ItemCode
			, CAST(TP_Customer_Tags.Mounting AS varchar(20)) AS Mounting
			, CAST(TP_Customer_Tags.SpecialityTag AS varchar(30)) AS SpecialityTag
			, ISNULL(CAST(TP_Customer_Tags.IsNonRevenue AS bit), 0) AS NonRevenueFlag
			, ISNULL(CAST(TP_Customer_Tags.UpdatedDate AS datetime2(3)), '1900-01-01') AS UpdatedDate
			, ISNULL(CAST(TP_Customer_Tags.LND_UpdateDate AS datetime2(3)), '1900-01-01') AS LND_UpdateDate
			, ISNULL(@Log_Start_Date, '1900-01-01') AS EDW_UpdateDate
		FROM LND_TBOS.TollPlus.TP_Customer_Tags
		WHERE LND_UpdateDate > @Last_CustomerTags_Date
		OPTION (LABEL = 'dbo.Dim_CustomerTag_NEW');

		SET  @Log_Message = 'Loaded ' + @StageTableName
		EXEC Utility.FastLog @Log_Source, @Log_Message, -1

		IF @Trace_Flag = 1 PRINT 'Calling: Utility.UpdateTableWithTable'
		EXEC Utility.UpdateTableWithTable @StageTableName, @TableName, @IdentifyingColumns, Null

		IF OBJECT_ID('dbo.Dim_CustomerTag_NEW','U') IS NOT NULL			DROP TABLE dbo.Dim_CustomerTag_NEW;

		SET @Log_Message = 'Completed Incremental load from: ' + CONVERT(VARCHAR(25),@Last_CustomerTags_Date,121)
	END

	IF @Trace_Flag = 1 PRINT @Log_Message
	EXEC Utility.ToLog @Log_Source, @Log_Start_Date, @Log_Message, 'I', NULL, NULL


END

/*###################################################################################################################
Example:
-------------------------------------------------------------------------------------------------------------------
EXEC dbo.Dim_CustomerTag_Load 1

EXEC Utility.FromLog 'dbo.Dim_CustomerTag', 1
SELECT 'LND_TBOS.TollPlus.TP_Customer_Tags' Table_Name, COUNT_BIG(1) Row_Count FROM LND_TBOS.TollPlus.TP_Customer_Tags
SELECT 'dbo.Dim_CustomerTag' Table_Name, COUNT_BIG(1) Row_Count FROM dbo.Dim_CustomerTag  
SELECT TOP 100 'dbo.Dim_CustomerTag' Table_Name, * FROM dbo.Dim_CustomerTag
===================================================================================================================*/
