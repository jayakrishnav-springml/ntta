CREATE PROC [dbo].[Fact_Host_Service_Event_Load] @IsFullLoad [BIT] AS
/*
###################################################################################################################
Proc Description: 
-------------------------------------------------------------------------------------------------------------------
Load dbo.dbo.Fact_Host_Service_Event. Depends on dbo.Dim_Host_Service_Metric_Load for Stage.Host_Service_Event data

The following 3 procs go together in tight sequence, as if all in one proc:
1. dbo.Dim_Host_Service_Metric_Load
2. dbo.Fact_Host_Service_Event_Load
3. dbo.Fact_Host_Service_Event_Metric_Load
===================================================================================================================
Change Log:
-------------------------------------------------------------------------------------------------------------------
CHG0039845	Shankar		2021-03-26	New!

===================================================================================================================
Example:
-------------------------------------------------------------------------------------------------------------------
EXEC dbo.Fact_Host_Service_Event_Load 0
SELECT TOP 1000 * FROM dbo.Fact_Host_Service_Event ORDER BY 1 DESC
SELECT * FROM Utility.ProcessLog ORDER BY 1 DESC
###################################################################################################################
*/

BEGIN

	BEGIN TRY

		-- DEBUG
		-- DECLARE @IsFullLoad BIT = 0

		DECLARE @TableName VARCHAR(100) = 'dbo.Fact_Host_Service_Event', @StageTableName VARCHAR(100) = 'dbo.Fact_Host_Service_Event_NEW', @IdentifyingColumns VARCHAR(100) = '[Host_Service_Event_ID]'
		DECLARE @Log_Source VARCHAR(100) = 'dbo.Fact_Host_Service_Event_Load', @Log_Start_Date DATETIME2(3) = SYSDATETIME()
		DECLARE @Log_Message VARCHAR(1000), @Trace_Flag BIT = 1 -- Testing
		DECLARE @Last_Updated_Date DATETIME2(3), @SQL VARCHAR(MAX), @CreateTableWith VARCHAR(MAX)
		DECLARE @Partition_Ranges VARCHAR(MAX), @FirstPartitionID INT = 202103, @LastPartitionID INT = CAST(CONVERT(VARCHAR(6),DATEADD(DAY,1,EOMONTH(SYSDATETIME(),1)),112) AS INT)

		IF	OBJECT_ID(@TableName) IS NULL
			SET @IsFullLoad = 1

		IF @IsFullLoad = 1
		BEGIN
			IF @Trace_Flag = 1 PRINT 'Calling: Utility.Get_PartitionDayIDRange_String from ' + CAST(@FirstPartitionID AS VARCHAR(10))+ ' till ' + CAST(@LastPartitionID AS VARCHAR(10))
			EXEC Utility.Get_PartitionDayIDRange_String @FirstPartitionID, @LastPartitionID, @Partition_Ranges OUTPUT
			SET @CreateTableWith = '(CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = HASH(Host_Service_Event_ID), PARTITION (Event_Day_ID RANGE RIGHT FOR VALUES (' + @Partition_Ranges + ')))'
			IF @Trace_Flag = 1 PRINT @CreateTableWith
			SET @Log_Message = 'Started Full load from the data populated by dbo.Dim_Host_Service_Metric_Load in Stage.Host_Service_Event'
		END
		ELSE
		BEGIN
			SET @CreateTableWith = '(CLUSTERED INDEX (' + @IdentifyingColumns + '), DISTRIBUTION = HASH(Host_Service_Event_ID))'
			IF @Trace_Flag = 1 PRINT @CreateTableWith
			IF @Trace_Flag = 1 PRINT 'Calling: Utility.Get_UpdatedDate for "Nagios Host_Service_Event Dim & Fact Tables"'
			EXEC Utility.Get_UpdatedDate 'Nagios Host_Service_Event Dim & Fact Tables', @Last_Updated_Date OUTPUT -- Info Call only, not for use in this proc
			SET @Log_Message = 'Started Incremental load with event data populated by dbo.Dim_Host_Service_Metric_Load in Stage.Host_Service_Event starting from ' + CONVERT(VARCHAR(25),@Last_Updated_Date,121)  
		END

		IF @Trace_Flag = 1 PRINT @Log_Message
		EXEC Utility.ToLog @Log_Source, @Log_Start_Date, @Log_Message, 'I', NULL, NULL

		--======================================================================
		--:: dbo.Fact_Host_Service_Event
		--======================================================================

		SET @SQL = '
		IF OBJECT_ID(''' + @StageTableName + ''',''U'') IS NOT NULL DROP TABLE ' + @StageTableName + '
		CREATE TABLE ' + @StageTableName + ' WITH ' + @CreateTableWith + ' AS
		SELECT 
			   ISNULL(CAST(S.Host_Service_Event_ID AS BIGINT), 0) AS Host_Service_Event_ID
			 , ISNULL(CAST(S.Nagios_Object_ID AS INT), 0) AS Nagios_Object_ID
			 , ISNULL(CAST(S.Event_Date AS DATETIME), ''1900-01-01'') AS Event_Date
			 , ISNULL(CAST(CONVERT(VARCHAR(8), S.Event_Date,112) AS INT),-1) AS Event_Day_ID
			 , ISNULL(CAST(DATEDIFF(SECOND,CAST(S.Event_Date AS DATE), S.Event_Date) AS INT),-1) AS Event_Time_ID
			 , ISNULL(CAST(ST.State_ID AS SMALLINT), 0) AS Host_Service_State_ID	
			 , CAST(S.Metric_Count AS TINYINT) AS Metric_Count
			 , CAST(S.LND_UpdateDate AS DATETIME2(3)) AS LND_UpdateDate
			 , CAST(SYSDATETIME() AS DATETIME2(3)) AS EDW_UpdateDate
		FROM	Stage.Host_Service_Event S
		JOIN	dbo.Dim_State ST 
				ON S.Host_Service_State = ST.State_value 
				AND ST.Object_Type = CASE WHEN S.Service IS NULL THEN ''Host'' ELSE ''Service'' END 	
		OPTION (LABEL = ''Load dbo.Fact_Host_Service_Event_NEW'');'

		IF @Trace_Flag = 1 EXEC Utility.LongPrint @SQL
		EXEC (@SQL)
		SET  @Log_Message = 'Loaded ' + @StageTableName
		EXEC Utility.ToLog @Log_Source, @Log_Start_Date, @Log_Message, 'I', -1, @SQL

		-- Create statistics and swap table
		IF @IsFullLoad = 1
		BEGIN
			SET @SQL = '
			CREATE STATISTICS STATS_' + REPLACE(@TableName,'.','_') + '_001 ON ' + @StageTableName + '(Nagios_Object_ID)
			CREATE STATISTICS STATS_' + REPLACE(@TableName,'.','_') + '_002 ON ' + @StageTableName + '(Event_Day_ID)
			CREATE STATISTICS STATS_' + REPLACE(@TableName,'.','_') + '_003 ON ' + @StageTableName + '(Event_Time_ID)
			CREATE STATISTICS STATS_' + REPLACE(@TableName,'.','_') + '_004 ON ' + @StageTableName + '(Event_Date)
			CREATE STATISTICS STATS_' + REPLACE(@TableName,'.','_') + '_005 ON ' + @StageTableName + '(Host_Service_State_ID)
			CREATE STATISTICS STATS_' + REPLACE(@TableName,'.','_') + '_006 ON ' + @StageTableName + '(Metric_Count)
			CREATE STATISTICS STATS_' + REPLACE(@TableName,'.','_') + '_101 ON ' + @StageTableName + '(LND_UpdateDate)
			CREATE STATISTICS STATS_' + REPLACE(@TableName,'.','_') + '_102 ON ' + @StageTableName + '(EDW_UpdateDate)
			'
			IF @Trace_Flag = 1 EXEC Utility.LongPrint @SQL
			EXEC (@SQL)
			
			-- Table swap!
			EXEC Utility.TableSwap @StageTableName, @TableName

			SET @Log_Message = 'Completed Full load'
		END
		ELSE
		BEGIN
			IF @Trace_Flag = 1 PRINT 'Calling: Utility.ManagePartitions_DateID'
			EXEC Utility.ManagePartitions_DateID @TableName, 'DayID:Month'

			IF @Trace_Flag = 1 PRINT 'Calling: Utility.PartitionSwitch_Range'
			EXEC Utility.PartitionSwitch_Range @StageTableName, @TableName, @IdentifyingColumns, Null

			SET @SQL = 'UPDATE STATISTICS  ' + @TableName
			IF @Trace_Flag = 1 EXEC Utility.LongPrint @SQL
			EXEC (@SQL)

			SET @Log_Message = 'Completed Incremental load from: ' + CONVERT(VARCHAR(25),@Last_Updated_Date,121)
		END

		EXEC Utility.ToLog @Log_Source, @Log_Start_Date, @Log_Message, 'I', -1, -1
	
	END	TRY

	BEGIN CATCH
		DECLARE @ERROR_MESSAGE VARCHAR(MAX) = ERROR_MESSAGE();
		SET  @Log_Message = '*** Error in dbo.Fact_Host_Service_Event_Load: ' + @ERROR_MESSAGE;
		EXEC Utility.ToLog @Log_Source, @Log_Start_Date, @Log_Message, 'E', NULL,-1
		THROW;  -- Rethrow the error!
	END CATCH

END


/*

--===============================================================================================================
-- DEVELOPER TESTING ZONE to thoroughly test the code for various scenarios
--===============================================================================================================
EXEC dbo.Fact_Host_Service_Event_Load 0
SELECT TOP 100 * FROM Utility.ProcessLog ORDER BY 1 DESC

SELECT * FROM Utility.LoadProcessControl
SELECT TOP 10000 * FROM dbo.Fact_Host_Service_Event

--DROP TABLE dbo.Fact_Host_Service_Event
--TRUNCATE TABLE dbo.Fact_Host_Service_Event
--TRUNCATE TABLE Utility.ProcessLog

--===============================================================================================================
-- DYNAMIC SQL 
--===============================================================================================================

IF OBJECT_ID('dbo.Fact_Host_Service_Event_NEW','U') IS NOT NULL DROP TABLE dbo.Fact_Host_Service_Event_NEW
CREATE TABLE dbo.Fact_Host_Service_Event_NEW WITH (CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = HASH(Host_Service_Event_ID), PARTITION (Event_Day_ID RANGE RIGHT FOR VALUES (20210301,20210401,20210501,20210601,20210701,20210801,20210901,20211001,20211101,20211201))) AS
SELECT 
		ISNULL(CAST(S.Host_Service_Event_ID AS BIGINT), 0) AS Host_Service_Event_ID
		, ISNULL(CAST(S.Nagios_Object_ID AS INT), 0) AS Nagios_Object_ID
		, ISNULL(CAST(S.Event_Date AS DATETIME), '1900-01-01') AS Event_Date
		, ISNULL(CAST(CONVERT(VARCHAR(8), S.Event_Date,112) AS INT),-1) AS Event_Day_ID
		, ISNULL(CAST(DATEDIFF(SECOND,CAST(S.Event_Date AS DATE), S.Event_Date) AS INT),-1) AS Event_Time_ID
		, ISNULL(CAST(ST.State_ID AS SMALLINT), 0) AS Host_Service_State_ID	
		, CAST(S.Metric_Count AS TINYINT) AS Metric_Count
		, CAST(S.LND_UpdateDate AS DATETIME2(3)) AS LND_UpdateDate
		, CAST(SYSDATETIME() AS DATETIME2(3)) AS EDW_UpdateDate
FROM	Stage.Host_Service_Event S
JOIN	dbo.Dim_State ST 
		ON S.Host_Service_State = ST.State_value 
		AND ST.Object_Type = CASE WHEN S.Service IS NULL THEN 'Host' ELSE 'Service' END 	
OPTION (LABEL = 'Load dbo.Fact_Host_Service_Event_NEW');

CREATE STATISTICS STATS_dbo_Fact_Host_Service_Event_001 ON dbo.Fact_Host_Service_Event_NEW(Nagios_Object_ID)
CREATE STATISTICS STATS_dbo_Fact_Host_Service_Event_002 ON dbo.Fact_Host_Service_Event_NEW(Event_Day_ID)
CREATE STATISTICS STATS_dbo_Fact_Host_Service_Event_003 ON dbo.Fact_Host_Service_Event_NEW(Event_Time_ID)
CREATE STATISTICS STATS_dbo_Fact_Host_Service_Event_004 ON dbo.Fact_Host_Service_Event_NEW(Event_Date)
CREATE STATISTICS STATS_dbo_Fact_Host_Service_Event_005 ON dbo.Fact_Host_Service_Event_NEW(Host_Service_State_ID)
CREATE STATISTICS STATS_dbo_Fact_Host_Service_Event_006 ON dbo.Fact_Host_Service_Event_NEW(Metric_Count)
CREATE STATISTICS STATS_dbo_Fact_Host_Service_Event_101 ON dbo.Fact_Host_Service_Event_NEW(LND_UpdateDate)
CREATE STATISTICS STATS_dbo_Fact_Host_Service_Event_102 ON dbo.Fact_Host_Service_Event_NEW(EDW_UpdateDate)

--===============================================================================================================
-- USEFUL DATA VALIDATION SCRIPTS for post prod move monitoring or for others to not reinvent the wheel
--===============================================================================================================
;WITH CTE AS
(
	SELECT  
		CAST(pf.boundary_value_on_right AS INT) AS boundary_value_on_right,
		CASE WHEN CAST(pf.boundary_value_on_right AS INT) = 1 
			THEN CASE WHEN rv.[value] IS NULL THEN 1 ELSE CAST(p.partition_number AS INT) + 1 END
			ELSE CAST(p.partition_number AS INT)
		END AS PartitionNum,
		CASE WHEN CAST(pf.boundary_value_on_right AS INT) = 1 
			THEN ISNULL(CAST(rv.[value] AS BIGINT),CAST(0 AS BIGINT))
			ELSE ISNULL(CAST(rv.[value] AS BIGINT),CAST(9223372036854775800 AS BIGINT))
		END AS NumberValueFrom 
	FROM      sys.schemas s
	JOIN      sys.Tables t                  ON t.[schema_id]      = s.[schema_id]
	JOIN      sys.partitions p              ON p.[object_id]      = t.[object_id] AND p.[index_id] <=1
	JOIN      sys.indexes i                 ON i.[object_id]      = p.[object_id] AND i.[index_id] = p.[index_id]
	JOIN      sys.data_spaces ds            ON ds.[data_space_id] = i.[data_space_id]
	LEFT JOIN sys.partition_schemes ps      ON ps.[data_space_id] = ds.[data_space_id]
	LEFT JOIN sys.partition_functions pf    ON pf.[function_id]   = ps.[function_id]
	LEFT JOIN sys.partition_range_values rv ON rv.[function_id]   = pf.[function_id] AND rv.[boundary_id] = p.[partition_number]
	WHERE s.[name] = 'dbo' AND t.[name] = 'Fact_Host_Service_Event'
)
SELECT
	PartitionNum,
	CASE WHEN CAST(boundary_value_on_right AS INT) = 1 
		THEN ISNULL(NumberValueFrom,0)
		ELSE ISNULL(LAG(NumberValueFrom) OVER (ORDER BY PartitionNum) + 1,CAST(0 AS BIGINT))
	END AS NumberValueFrom, 
	CASE WHEN CAST(boundary_value_on_right AS INT) = 1 
		THEN ISNULL(LEAD(NumberValueFrom) OVER (ORDER BY PartitionNum) - 1, CAST(9223372036854775800 AS BIGINT))
		ELSE ISNULL(NumberValueFrom,CAST(9223372036854775800 AS BIGINT))
	END AS NumberValueTo 
FROM CTE

*/


