CREATE PROC [dbo].[Fact_Host_Service_Event_Metric_Summary_Load] @IsFullLoad [BIT] AS
/*
###################################################################################################################
Proc Description: 
-------------------------------------------------------------------------------------------------------------------
Load dbo.dbo.Fact_Host_Service_Event_Metric_Summary_Load

The following 5 procs GO TOGETHER IN SEQUENCE, as if it's all in one proc:
1. dbo.Dim_Host_Service_Metric_Load
2. dbo.Fact_Host_Service_Event_Load
3. dbo.Fact_Host_Service_Event_Metric_Load
4. dbo.Fact_Host_Service_Event_Summary_Load
5. dbo.Fact_Host_Service_Event_Metric_Summary_Load
===================================================================================================================
Change Log:
-------------------------------------------------------------------------------------------------------------------
CHG0039980  Shankar	    2021-11-15	New!

===================================================================================================================
Example:
-------------------------------------------------------------------------------------------------------------------
SELECT 'LoadProcessControl Before' SRC, * FROM Utility.LoadProcessControl
EXEC dbo.Fact_Host_Service_Event_Metric_Summary_Load 1
SELECT * FROM Utility.ProcessLog WHERE LogSource LIKE 'dbo.Fact_Host_Service_Event_Metric_Summary_Load%' ORDER BY 1 DESC
SELECT 'LoadProcessControl After' SRC, * FROM Utility.LoadProcessControl

SELECT TOP 1000 * FROM dbo.Fact_Host_Service_Event_Metric_Summary ORDER BY 1 DESC
###################################################################################################################
*/


BEGIN

	BEGIN TRY

		-- DEBUG
		-- DECLARE @IsFullLoad BIT = 0

		DECLARE @Log_Source VARCHAR(100) = 'dbo.Fact_Host_Service_Event_Metric_Summary_Load', @Log_Start_Date DATETIME2(3) = SYSDATETIME()
		DECLARE @Log_Message VARCHAR(1000), @Trace_Flag BIT = 1 -- Testing
		DECLARE @Last_Updated_Date DATETIME2(3), @Last_Updated_DayID INT, @SQL VARCHAR(MAX), @CreateTableWith VARCHAR(MAX)

		IF	OBJECT_ID('dbo.Fact_Host_Service_Event_Metric_Summary') IS NULL
			SET @IsFullLoad = 1

		--======================================================================
		--:: dbo.Fact_Host_Service_Event_Metric_Summary
		--======================================================================
		IF @IsFullLoad = 1
		BEGIN
			SET @Log_Message = 'Started full load of dbo.Fact_Host_Service_Event_Metric_Summary'
			IF @Trace_Flag = 1 PRINT @Log_Message
			EXEC Utility.ToLog @Log_Source, @Log_Start_Date, @Log_Message, 'I', NULL, NULL

			IF OBJECT_ID('dbo.Fact_Host_Service_Event_Metric_Summary_NEW','U') IS NOT NULL DROP TABLE dbo.Fact_Host_Service_Event_Metric_Summary_NEW
			CREATE TABLE dbo.Fact_Host_Service_Event_Metric_Summary_NEW WITH (CLUSTERED INDEX (Event_Metric_Summary_ID), DISTRIBUTION = HASH(Event_Metric_Summary_ID)) AS 
			SELECT
				  ISNULL(CAST(ROW_NUMBER() OVER(ORDER BY Event_Day_ID, Host_Service_Metric_ID, Metric_State_ID) AS INT),0) Event_Metric_Summary_ID
				, Event_Day_ID
				, Host_Service_Metric_ID
				, Metric_State_ID
				, CAST(MAX(Metric_Unit) AS VARCHAR(5)) Metric_Unit
				, CAST(SUM(Metric_Value) AS DECIMAL(19,8)) Total_Metric_Value
				, CAST(COUNT(1) AS INT) Metric_Value_Count
				, CAST(MAX(LND_UpdateDate) AS DATETIME2(3)) LND_UpdateDate
				, CAST(SYSDATETIME() AS DATETIME2(3)) EDW_UpdateDate
			FROM dbo.Fact_Host_Service_Event_Metric
			GROUP BY 
				  Event_Day_ID
				, Host_Service_Metric_ID
				, Metric_State_ID
			OPTION (LABEL = 'Load dbo.Fact_Host_Service_Event_Metric_Summary_NEW');

		END
		ELSE
		BEGIN
			IF @Trace_Flag = 1 PRINT 'Calling: Utility.Get_UpdatedDate for "Nagios Host_Service_Event Dim & Fact Tables"'
			EXEC Utility.Get_UpdatedDate 'Nagios Host_Service_Event Dim & Fact Tables', @Last_Updated_Date OUTPUT
			SELECT @Last_Updated_DayID = CONVERT(INT,CONVERT(VARCHAR,DATEADD(DAY,-1,ISNULL(@Last_Updated_Date,'11/01/2021')),112))

			DECLARE @Max_ID INT
			SELECT @Max_ID = MAX(Event_Metric_Summary_ID) FROM dbo.Fact_Host_Service_Event_Metric_Summary WHERE Event_Day_ID < @Last_Updated_DayID
			SET @Log_Message = 'Started incremental load of dbo.Fact_Host_Service_Event_Metric_Summary starting from ' + CONVERT(VARCHAR,@Last_Updated_DayID) + '. @Max_ID: ' + CONVERT(VARCHAR,ISNULL(@Max_ID,0))
			IF @Trace_Flag = 1 PRINT @Log_Message
			EXEC Utility.ToLog @Log_Source, @Log_Start_Date, @Log_Message, 'I', NULL, NULL

 			IF OBJECT_ID('dbo.Fact_Host_Service_Event_Metric_Summary_NEW','U') IS NOT NULL DROP TABLE dbo.Fact_Host_Service_Event_Metric_Summary_NEW
			CREATE TABLE dbo.Fact_Host_Service_Event_Metric_Summary_NEW WITH (CLUSTERED INDEX (Event_Metric_Summary_ID), DISTRIBUTION = HASH(Event_Metric_Summary_ID)) AS 
			SELECT  
				  Event_Metric_Summary_ID
				, Event_Day_ID
				, Host_Service_Metric_ID
				, Metric_State_ID
				, Metric_Unit
				, Total_Metric_Value
				, Metric_Value_Count
				, LND_UpdateDate
				, EDW_UpdateDate
			FROM dbo.Fact_Host_Service_Event_Metric_Summary
			WHERE Event_Day_ID < @Last_Updated_DayID
			UNION ALL
			SELECT
			      ISNULL(ISNULL(@Max_ID,0) + CAST(ROW_NUMBER() OVER(ORDER BY Event_Day_ID, Host_Service_Metric_ID, Metric_State_ID) AS INT),0) Event_Metric_Summary_ID
				, Event_Day_ID
				, Host_Service_Metric_ID
				, Metric_State_ID
				, CAST(MAX(Metric_Unit) AS VARCHAR(5)) Metric_Unit
				, CAST(SUM(Metric_Value) AS DECIMAL(19,8)) Total_Metric_Value
				, CAST(COUNT(1) AS INT) Metric_Value_Count
				, CAST(MAX(LND_UpdateDate) AS DATETIME2(3)) LND_UpdateDate
				, CAST(SYSDATETIME() AS DATETIME2(3)) EDW_UpdateDate
			FROM dbo.Fact_Host_Service_Event_Metric
			WHERE Event_Day_ID >= @Last_Updated_DayID
			GROUP BY 
				  Event_Day_ID
				, Host_Service_Metric_ID
				, Metric_State_ID
			OPTION (LABEL = 'Load dbo.Fact_Host_Service_Event_Metric_Summary_NEW');

		END

		SET  @Log_Message = 'Loaded dbo.Fact_Host_Service_Event_Metric_Summary_NEW'
		EXEC Utility.ToLog @Log_Source, @Log_Start_Date, @Log_Message, 'I', -1, @SQL

		CREATE STATISTICS STATS_dbo_Fact_Host_Service_Event_Metric_Summary_001 ON dbo.Fact_Host_Service_Event_Metric_Summary_NEW(Host_Service_Metric_ID)
		CREATE STATISTICS STATS_dbo_Fact_Host_Service_Event_Metric_Summary_002 ON dbo.Fact_Host_Service_Event_Metric_Summary_NEW(Event_Day_ID)
		CREATE STATISTICS STATS_dbo_Fact_Host_Service_Event_Metric_Summary_003 ON dbo.Fact_Host_Service_Event_Metric_Summary_NEW(Metric_State_ID)
		CREATE STATISTICS STATS_dbo_Fact_Host_Service_Event_Metric_Summary_004 ON dbo.Fact_Host_Service_Event_Metric_Summary_NEW(Total_Metric_Value)
		CREATE STATISTICS STATS_dbo_Fact_Host_Service_Event_Metric_Summary_005 ON dbo.Fact_Host_Service_Event_Metric_Summary_NEW(Metric_Value_Count)
		CREATE STATISTICS STATS_dbo_Fact_Host_Service_Event_Metric_Summary_006 ON dbo.Fact_Host_Service_Event_Metric_Summary_NEW(Metric_Unit)
 
		EXEC Utility.TableSwap 'dbo.Fact_Host_Service_Event_Metric_Summary_NEW', 'dbo.Fact_Host_Service_Event_Metric_Summary'

		IF @Trace_Flag = 1 PRINT @Log_Message
		EXEC Utility.ToLog @Log_Source, @Log_Start_Date, 'Created Statistics and completed Table Swap', 'I', NULL, NULL

		--:: Advance the Last_Updated_Date for next run.
		IF @IsFullLoad = 0
		BEGIN
			SET @Last_Updated_Date = NULL
			EXEC Utility.Set_UpdatedDate 'Nagios Host_Service_Event Dim & Fact Tables', 'dbo.Fact_Host_Service_Event_Metric_Summary', @Last_Updated_Date OUTPUT
			SET @Log_Message = 'Advanced Last Update date for the next run as ' + ISNULL(CONVERT(VARCHAR(25),@Last_Updated_Date,121),'?') 
			EXEC Utility.ToLog @Log_Source, @Log_Start_Date, @Log_Message, 'I', NULL, NULL
		END

		SET @Log_Message = CASE WHEN @IsFullLoad = 1 THEN 'Completed full load' ELSE 'Completed incremental load' END
		EXEC Utility.ToLog @Log_Source, @Log_Start_Date, @Log_Message, 'I', NULL, NULL

	END	TRY

	BEGIN CATCH
		DECLARE @ERROR_MESSAGE VARCHAR(MAX) = ERROR_MESSAGE();
		SET  @Log_Message = '*** Error in dbo.Fact_Host_Service_Event_Metric_Summary_Load: ' + @ERROR_MESSAGE;
		EXEC Utility.ToLog @Log_Source, @Log_Start_Date, @Log_Message, 'E', NULL, NULL
		THROW;  -- Rethrow the error!
	END CATCH

END


/*
SELECT 'LoadProcessControl Before' SRC, * FROM Utility.LoadProcessControl
EXEC dbo.Fact_Host_Service_Event_Metric_Summary_Load 0
SELECT * FROM Utility.ProcessLog WHERE LogSource LIKE 'dbo.Fact_Host_Service_Event_Metric_Summary_Load%' ORDER BY 1 DESC
SELECT 'LoadProcessControl After' SRC, * FROM Utility.LoadProcessControl

SELECT TOP 1000 * FROM dbo.Fact_Host_Service_Event_Metric_Summary ORDER BY 1 DESC

--===============================================================================================================
-- DEVELOPER TESTING ZONE to thoroughly test the code for various scenarios
--===============================================================================================================
SELECT Event_Day_ID, MIN(Event_Metric_Summary_ID) Event_Metric_Summary_ID_From, MAX(Event_Metric_Summary_ID) Event_Metric_Summary_ID_To, COUNT_BIG(1) RC 
	FROM dbo.Fact_Host_Service_Event_Metric_Summary 
GROUP BY Event_Day_ID
ORDER BY Event_Day_ID DESC

*/


