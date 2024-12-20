CREATE PROC [Utility].[Get_APS_RowCount] AS

/*
###################################################################################################################
Proc Description: 
-------------------------------------------------------------------------------------------------------------------
Load Daily Row Counts of Landing TBOS tables in Stage.APS_DailyRowCount. 
===================================================================================================================
Change Log:
-------------------------------------------------------------------------------------------------------------------
CHG0038211		Shankar		2021-01-18	New!
CHG0040170		Shankar		2021-12-22	Misc changes for better compare results and performance
CHG0042840		Sagarika    2023-04-19	Include LND_UpdateType = 'A' to Avoid wrong Source VS
                                        Landing Compariosn Numbers
===================================================================================================================
Example:
-------------------------------------------------------------------------------------------------------------------
EXEC Utility.Get_APS_RowCount 
SELECT * FROM Utility.ProcessLog Where LogSource like 'Utility.Get_APS_RowCount%' ORDER BY 1 DESC

SELECT TOP 1000 'Stage.APS_DailyRowCount' TableName, * FROM Stage.APS_DailyRowCount ORDER BY 2,3,4 DESC
###################################################################################################################
*/

BEGIN

	BEGIN TRY

		DECLARE @Log_Source VARCHAR(100) = 'Utility.Get_APS_RowCount', @Log_Start_Date DATETIME2 (3) = SYSDATETIME() 
		DECLARE @Log_Message VARCHAR(1000), @Row_Count BIGINT, @Trace_Flag BIT = 0 -- Testing
		EXEC    Utility.ToLog @Log_Source, @Log_Start_Date, 'Started APS Row Counts', 'I', NULL, NULL

		DECLARE @Counter SMALLINT = 1, @SQL_Line VARCHAR(1000), @SQL VARCHAR(MAX) = '', @TablesCount SMALLINT, @APS_SQL VARCHAR(MAX)
		
		--::==================================================================================================
		--:: Daily RowCount script: Compare Daily row counts by CreatedDate for each CDC table 
		--::==================================================================================================

		IF OBJECT_ID('tempdb..#RowCounts_SQL') IS NOT NULL DROP Table #RowCounts_SQL;
		CREATE Table #RowCounts_SQL WITH (HEAP, DISTRIBUTION = Replicate) AS 
		SELECT	ROW_NUMBER() OVER (ORDER BY DataBaseName,FullName) RN, 
				'SELECT ''' + DataBaseName + ''' DataBaseName,''' + FullName + ''' TableName, ' + 
				CASE WHEN FullName <> 'EIP.Results_Log' THEN 'CAST(CreatedDate AS DATE)'   
				ELSE 'CAST(ISNULL(EIPCompletedDate,EIPReceivedDate) AS DATE)' END + ' AS CreatedDate, ' + 
				'COUNT_BIG(1) SourceRowCount, CAST(SYSDATETIME() AS DATETIME2(3)) AS LND_UpdateDate' + CHAR(10) + 
				'FROM	LND_TBOS.' + FullName + CHAR(10) +  
				'WHERE	LND_UpdateType NOT IN (''D'',''A'')' + CHAR(10) +
				CASE WHEN FullName = 'TollPlus.TP_Image_Review_Results' THEN 'AND CreatedDate	>= ''2019-01-01 00:00''' + CHAR(10) ELSE '' END +  
				'GROUP BY ' + CASE WHEN FullName <> 'EIP.Results_Log' THEN 'CAST(CreatedDate AS DATE)'	ELSE 'CAST(ISNULL(EIPCompletedDate,EIPReceivedDate) AS DATE)' END +  + CHAR(10) + 
				'UNION ALL' + CHAR(10) AS SQL_Line    
		FROM Utility.TableLoadParameters
		WHERE Active = 1 AND CDCFlag = 1

		SELECT @TablesCount = MAX(RN) FROM #RowCounts_SQL

		WHILE (@Counter <= @TablesCount)
		BEGIN

			SELECT @SQL_Line = SQL_Line 
			FROM #RowCounts_SQL M
			WHERE M.RN = @Counter

			SET @SQL = @SQL + CASE WHEN @Counter = @TablesCount THEN REPLACE(@SQL_Line,'UNION ALL','') ELSE @SQL_Line END

			SET @Counter += 1
		END

		SET @SQL = 'TRUNCATE TABLE Stage.APS_DailyRowCount' + CHAR(10) + 'INSERT Stage.APS_DailyRowCount' + CHAR(10) + @SQL
		IF @Trace_Flag = 1 EXEC Utility.LongPrint @SQL

		--:: Get Row Counts SQL
		EXEC (@SQL)
		SET  @Log_Message = 'Loaded Daily Row Counts for ' + CONVERT(VARCHAR,@TablesCount) + ' CDC Tables in APS LND_TBOS database' 
		EXEC Utility.ToLog @Log_Source, @Log_Start_Date, @Log_Message, 'I', -1, @SQL

		EXEC Utility.ToLog @Log_Source, @Log_Start_Date, 'Completed APS Row Counts', 'I', NULL, NULL
		
		-- Show results
		IF @Trace_Flag = 1 EXEC Utility.FromLog @Log_Source, @Log_Start_Date
		IF @Trace_Flag = 1 SELECT TOP 1000 'Stage.APS_DailyRowCount' TableName, * FROM Stage.APS_DailyRowCount ORDER BY 2,3,4 DESC
	
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
EXEC Utility.Get_APS_RowCount

EXEC Utility.FromLog 'Get_APS_RowCount', 1
SELECT TOP 1000 'Stage.APS_DailyRowCount' TableName, * FROM Stage.APS_DailyRowCount ORDER BY 2,3,4 DESC
*/


