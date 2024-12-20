CREATE PROC [dbo].[Fact_Host_Service_Event_Metric_Load] @IsFullLoad [BIT] AS
/*
###################################################################################################################
Proc Description: 
-------------------------------------------------------------------------------------------------------------------
Load dbo.dbo.Fact_Host_Service_Event_Metric_Load

The following 3 procs go together in tight sequence, as if all in one proc:
1. dbo.Dim_Host_Service_Metric_Load
2. dbo.Fact_Host_Service_Event_Load
3. dbo.Fact_Host_Service_Event_Metric_Load
===================================================================================================================
Change Log:
-------------------------------------------------------------------------------------------------------------------
CHG0039845	Shankar		2021-03-26	New!
CHG0039980  Shankar	    2021-11-15  Moved the logic to set load control date for next run to Metric Summary table load.
===================================================================================================================
Example:
-------------------------------------------------------------------------------------------------------------------
SELECT 'LoadProcessControl Before' SRC, * FROM Utility.LoadProcessControl
EXEC dbo.Fact_Host_Service_Event_Metric_Load 1
SELECT * FROM Utility.ProcessLog ORDER BY 1 DESC
SELECT 'LoadProcessControl After' SRC, * FROM Utility.LoadProcessControl

SELECT TOP 1000 * FROM dbo.Fact_Host_Service_Event_Metric ORDER BY 1 DESC
###################################################################################################################
*/

BEGIN

	BEGIN TRY

		-- DEBUG
		-- DECLARE @IsFullLoad BIT = 0

		DECLARE @TableName VARCHAR(100) = 'dbo.Fact_Host_Service_Event_Metric', @StageTableName VARCHAR(100) = 'dbo.Fact_Host_Service_Event_Metric_NEW', @IdentifyingColumns VARCHAR(100) = '[Host_Service_Event_ID]'
		DECLARE @Log_Source VARCHAR(100) = 'dbo.Fact_Host_Service_Event_Metric_Load', @Log_Start_Date DATETIME2(3) = SYSDATETIME()
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
			SET @CreateTableWith = '(CLUSTERED INDEX (' + @IdentifyingColumns + ' DESC), DISTRIBUTION = HASH(Host_Service_Event_ID))'
			IF @Trace_Flag = 1 PRINT @CreateTableWith
			IF @Trace_Flag = 1 PRINT 'Calling: Utility.Get_UpdatedDate for "Nagios Host_Service_Event Dim & Fact Tables"'
			EXEC Utility.Get_UpdatedDate 'Nagios Host_Service_Event Dim & Fact Tables', @Last_Updated_Date OUTPUT -- Info Call only, not for use in this proc
			SET @Log_Message = 'Started Incremental load with parsed event metric data available in Stage.Host_Service_Metric_Data starting from ' + CONVERT(VARCHAR(25),@Last_Updated_Date,121)  
		END

		IF @Trace_Flag = 1 PRINT @Log_Message
		EXEC Utility.ToLog @Log_Source, @Log_Start_Date, @Log_Message, 'I', NULL, NULL

		--======================================================================
		--:: dbo.Fact_Host_Service_Event_Metric
		--======================================================================
		SET @SQL = '
		IF OBJECT_ID(''' + @StageTableName + ''',''U'') IS NOT NULL DROP TABLE ' + @StageTableName + '
		CREATE TABLE ' + @StageTableName + ' WITH ' + @CreateTableWith + ' AS
		SELECT	 
			   ISNULL(CAST(S.Host_Service_Event_ID AS BIGINT), 0) AS Host_Service_Event_ID
			 , ISNULL(CAST(M.Host_Service_Metric_ID AS INT), -1) AS Host_Service_Metric_ID	
			 , ISNULL(CAST(''20''+LEFT(LEFT(CONVERT(VARCHAR,S.Host_Service_Event_ID),12),6) AS INT),-1) AS Event_Day_ID
			 , ISNULL(CAST(DATEDIFF(SECOND,CONVERT(DATE,STUFF(STUFF(STUFF(LEFT(CONVERT(VARCHAR,S.Host_Service_Event_ID),12),11,0,'':''),9,0,'':''),7,0,'' '')),CONVERT(DATETIME,STUFF(STUFF(STUFF(LEFT(CONVERT(VARCHAR,S.Host_Service_Event_ID),12),11,0,'':''),9,0,'':''),7,0,'' ''))) AS INT),-1) AS Event_Time_ID
			 , ISNULL(CAST(ST.State_ID AS SMALLINT), -1) AS Metric_State_ID	
			 , ISNULL(CAST(STUFF(STUFF(STUFF(LEFT(CONVERT(VARCHAR,S.Host_Service_Event_ID),12),11,0,'':''),9,0,'':''),7,0,'' '') AS DATETIME), ''1900-01-01'') AS Event_Date
			 , ISNULL(CAST(S.Metric_Index AS SMALLINT), -1) AS Metric_Index	
			 , CAST(S.Metric_Value AS DECIMAL(19,8)) AS Metric_Value
			 , CAST(S.Metric_Unit AS VARCHAR(5)) AS Metric_Unit
			 , CAST(S.Warning_Value AS DECIMAL(19,8)) AS Warning_Value
			 , CAST(S.Critical_Value AS DECIMAL(19,8)) AS Critical_Value
			 , CAST(S.Min_Value AS DECIMAL(19,8)) AS Min_Value
			 , CAST(S.Max_Value AS DECIMAL(19,8)) AS Max_Value
			 , CAST(S.Percent_Warning AS DECIMAL(19,2)) AS Percent_Warning
			 , CAST(S.Percent_Critical AS DECIMAL(19,2)) AS Percent_Critical
			 , CAST(S.Percent_Max AS DECIMAL(19,2)) AS Percent_Max
			 , CAST(S.LND_UpdateDate AS DATETIME2(3)) AS LND_UpdateDate
			 , CAST(SYSDATETIME() AS DATETIME2(3)) AS EDW_UpdateDate

		FROM	Stage.Host_Service_Metric_Data S 
		JOIN	dbo.Dim_State ST 
				ON S.Metric_State = ST.State_value 
				AND ST.Object_Type = CASE WHEN S.Service IS NULL THEN ''Host'' ELSE ''Service'' END 	
		JOIN	dbo.Dim_Host_Service_Metric M
				ON S.Nagios_Object_ID = M.Nagios_Object_ID
				AND S.Metric_Name = M.Metric_Name
		OPTION (LABEL = ''Load dbo.Fact_Host_Service_Event_Metric_NEW'');'

		IF @Trace_Flag = 1 EXEC Utility.LongPrint @SQL
		EXEC (@SQL)
		SET  @Log_Message = 'Loaded ' + @StageTableName
		EXEC Utility.ToLog @Log_Source, @Log_Start_Date, @Log_Message, 'I', -1, @SQL

		-- Create statistics and swap table
		IF @IsFullLoad = 1
		BEGIN
			SET @SQL = '
			CREATE STATISTICS STATS_' + REPLACE(@TableName,'.','_') + '_001 ON ' + @StageTableName + '(Host_Service_Metric_ID)
			CREATE STATISTICS STATS_' + REPLACE(@TableName,'.','_') + '_002 ON ' + @StageTableName + '(Event_Day_ID)
			CREATE STATISTICS STATS_' + REPLACE(@TableName,'.','_') + '_003 ON ' + @StageTableName + '(Event_Time_ID)
			CREATE STATISTICS STATS_' + REPLACE(@TableName,'.','_') + '_004 ON ' + @StageTableName + '(Event_Date)
			CREATE STATISTICS STATS_' + REPLACE(@TableName,'.','_') + '_006 ON ' + @StageTableName + '(Metric_State_ID)
			CREATE STATISTICS STATS_' + REPLACE(@TableName,'.','_') + '_007 ON ' + @StageTableName + '(Metric_Index)
			CREATE STATISTICS STATS_' + REPLACE(@TableName,'.','_') + '_008 ON ' + @StageTableName + '(Metric_Value)
			CREATE STATISTICS STATS_' + REPLACE(@TableName,'.','_') + '_009 ON ' + @StageTableName + '(Metric_Unit)
			CREATE STATISTICS STATS_' + REPLACE(@TableName,'.','_') + '_010 ON ' + @StageTableName + '(Host_Service_Metric_ID,Event_Day_ID)
			CREATE STATISTICS STATS_' + REPLACE(@TableName,'.','_') + '_011 ON ' + @StageTableName + '(LND_UpdateDate)
			CREATE STATISTICS STATS_' + REPLACE(@TableName,'.','_') + '_012 ON ' + @StageTableName + '(EDW_UpdateDate)
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

			SET @Log_Message = 'Completed Incremental load from ' + CONVERT(VARCHAR(25),@Last_Updated_Date,121)
		END

		EXEC Utility.ToLog @Log_Source, @Log_Start_Date, @Log_Message, 'I', NULL, NULL

	END	TRY

	BEGIN CATCH
		DECLARE @ERROR_MESSAGE VARCHAR(MAX) = ERROR_MESSAGE();
		SET  @Log_Message = '*** Error in dbo.Fact_Host_Service_Event_Metric_Load: ' + @ERROR_MESSAGE;
		EXEC Utility.ToLog @Log_Source, @Log_Start_Date, @Log_Message, 'E', NULL, NULL
		THROW;  -- Rethrow the error!
	END CATCH

END


/*
SELECT 'LoadProcessControl Before' SRC, * FROM Utility.LoadProcessControl
EXEC dbo.Fact_Host_Service_Event_Metric_Load 1
SELECT * FROM Utility.ProcessLog ORDER BY 1 DESC
SELECT 'LoadProcessControl After' SRC, * FROM Utility.LoadProcessControl

SELECT TOP 1000 * FROM dbo.Fact_Host_Service_Event_Metric ORDER BY 1 DESC

--===============================================================================================================
-- DEVELOPER TESTING ZONE to thoroughly test the code for various scenarios
--===============================================================================================================

SELECT 'LoadProcessControl Before' SRC, * FROM Utility.LoadProcessControl
EXEC dbo.Fact_Host_Service_Event_Metric_Load 0
SELECT * FROM Utility.ProcessLog ORDER BY 1 DESC
SELECT 'LoadProcessControl After' SRC, * FROM Utility.LoadProcessControl
--:: Event Metric fact table
SELECT	TOP 10000 f.Host_Service_Event_ID, f.Event_Date, M.*, F.* 
FROM	dbo.Fact_Host_Service_Event_Metric F
JOIN	dbo.Dim_Host_Service_Metric M 
		ON F.Host_Service_Metric_ID = M.Host_Service_Metric_ID		
WHERE	M.Host_Facility = 'DNT'
		AND M.Host_Type = 'UPS'
		AND M.Service = 'UPS Temperature'
		AND F.Event_Date > '9/1/2019'
ORDER BY F.Host_Service_Event_ID, Metric_Suffix

SELECT	TOP 10000 FM.Host_Service_Event_ID, FM.Event_Date, FE.Nagios_Object_ID, M.Host_type, M.Host, M.Service, ES.State_Desc Event_State, MS.State_Desc Metric_State, M.*, FM.* 
FROM	dbo.Fact_Host_Service_Event FE 
JOIN	dbo.Fact_Host_Service_Event_Metric FM
		ON FE.Host_Service_Event_ID = FM.Host_Service_Event_ID
JOIN	dbo.Dim_Host_Service_Metric M 
		ON FM.Host_Service_Metric_ID = M.Host_Service_Metric_ID
JOIN	dbo.Dim_State ES
		ON FE.Host_Service_State_ID = ES.State_ID
JOIN	dbo.Dim_State MS
		ON FM.Metric_State_ID = MS.State_ID
WHERE	M.Host_Type = 'UPS'  
--AND		FM.Event_Day_ID = 20190904
AND		M.Host = '360-DEBLN-1-UPS'
ORDER BY FM.Host_Service_Event_ID, Metric_Suffix

--===============================================================================================================
-- DYNAMIC SQL OUTPUT
--===============================================================================================================

IF OBJECT_ID('dbo.Fact_Host_Service_Event_Metric_NEW','U') IS NOT NULL DROP TABLE dbo.Fact_Host_Service_Event_Metric_NEW
CREATE TABLE dbo.Fact_Host_Service_Event_Metric_NEW WITH (CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = HASH(Host_Service_Event_ID), PARTITION (Event_Day_ID RANGE RIGHT FOR VALUES (20210301,20210401,20210501,20210601,20210701,20210801,20210901,20211001,20211101,20211201))) AS
SELECT	 
		ISNULL(CAST(S.Host_Service_Event_ID AS BIGINT), 0) AS Host_Service_Event_ID
		, ISNULL(CAST(M.Host_Service_Metric_ID AS INT), -1) AS Host_Service_Metric_ID	
		, ISNULL(CAST('20'+LEFT(LEFT(CONVERT(VARCHAR,S.Host_Service_Event_ID),12),6) AS INT),-1) AS Event_Day_ID
		, ISNULL(CAST(DATEDIFF(SECOND,CONVERT(DATE,STUFF(STUFF(STUFF(LEFT(CONVERT(VARCHAR,S.Host_Service_Event_ID),12),11,0,':'),9,0,':'),7,0,' ')),CONVERT(DATETIME,STUFF(STUFF(STUFF(LEFT(CONVERT(VARCHAR,S.Host_Service_Event_ID),12),11,0,':'),9,0,':'),7,0,' '))) AS INT),-1) AS Event_Time_ID
		, ISNULL(CAST(ST.State_ID AS SMALLINT), -1) AS Metric_State_ID	
		, ISNULL(CAST(STUFF(STUFF(STUFF(LEFT(CONVERT(VARCHAR,S.Host_Service_Event_ID),12),11,0,':'),9,0,':'),7,0,' ') AS DATETIME), '1900-01-01') AS Event_Date
		, ISNULL(CAST(S.Metric_Index AS SMALLINT), -1) AS Metric_Index	
		, CAST(S.Metric_Value AS DECIMAL(19,8)) AS Metric_Value
		, CAST(S.Metric_Unit AS VARCHAR(5)) AS Metric_Unit
		, CAST(S.Warning_Value AS DECIMAL(19,8)) AS Warning_Value
		, CAST(S.Critical_Value AS DECIMAL(19,8)) AS Critical_Value
		, CAST(S.Min_Value AS DECIMAL(19,8)) AS Min_Value
		, CAST(S.Max_Value AS DECIMAL(19,8)) AS Max_Value
		, CAST(S.Percent_Warning AS DECIMAL(19,2)) AS Percent_Warning
		, CAST(S.Percent_Critical AS DECIMAL(19,2)) AS Percent_Critical
		, CAST(S.Percent_Max AS DECIMAL(19,2)) AS Percent_Max
		, CAST(S.LND_UpdateDate AS DATETIME2(3)) AS LND_UpdateDate
		, CAST(SYSDATETIME() AS DATETIME2(3)) AS EDW_UpdateDate

FROM	Stage.Host_Service_Metric_Data S 
JOIN	dbo.Dim_State ST 
		ON S.Metric_State = ST.State_value 
		AND ST.Object_Type = CASE WHEN S.Service IS NULL THEN 'Host' ELSE 'Service' END 	
JOIN	dbo.Dim_Host_Service_Metric M
		ON S.Nagios_Object_ID = M.Nagios_Object_ID
		AND S.Metric_Name = M.Metric_Name
OPTION (LABEL = 'Load dbo.Fact_Host_Service_Event_Metric_NEW');

	CREATE STATISTICS STATS_dbo_Fact_Host_Service_Event_Metric_001 ON dbo.Fact_Host_Service_Event_Metric_NEW(Host_Service_Metric_ID)
	CREATE STATISTICS STATS_dbo_Fact_Host_Service_Event_Metric_002 ON dbo.Fact_Host_Service_Event_Metric_NEW(Event_Day_ID)
	CREATE STATISTICS STATS_dbo_Fact_Host_Service_Event_Metric_003 ON dbo.Fact_Host_Service_Event_Metric_NEW(Event_Time_ID)
	CREATE STATISTICS STATS_dbo_Fact_Host_Service_Event_Metric_004 ON dbo.Fact_Host_Service_Event_Metric_NEW(Event_Date)
	CREATE STATISTICS STATS_dbo_Fact_Host_Service_Event_Metric_006 ON dbo.Fact_Host_Service_Event_Metric_NEW(Metric_State_ID)
	CREATE STATISTICS STATS_dbo_Fact_Host_Service_Event_Metric_007 ON dbo.Fact_Host_Service_Event_Metric_NEW(Metric_Index)
	CREATE STATISTICS STATS_dbo_Fact_Host_Service_Event_Metric_008 ON dbo.Fact_Host_Service_Event_Metric_NEW(Metric_Value)
	CREATE STATISTICS STATS_dbo_Fact_Host_Service_Event_Metric_009 ON dbo.Fact_Host_Service_Event_Metric_NEW(Metric_Unit)
	CREATE STATISTICS STATS_dbo_Fact_Host_Service_Event_Metric_010 ON dbo.Fact_Host_Service_Event_Metric_NEW(Host_Service_Metric_ID,Event_Day_ID)
	CREATE STATISTICS STATS_dbo_Fact_Host_Service_Event_Metric_011 ON dbo.Fact_Host_Service_Event_Metric_NEW(LND_UpdateDate)
	CREATE STATISTICS STATS_dbo_Fact_Host_Service_Event_Metric_012 ON dbo.Fact_Host_Service_Event_Metric_NEW(EDW_UpdateDate)


--===============================================================================================================
-- USEFUL DATA VALIDATION SCRIPTS for post prod move monitoring or for others to not reinvent the wheel
--===============================================================================================================

*/


