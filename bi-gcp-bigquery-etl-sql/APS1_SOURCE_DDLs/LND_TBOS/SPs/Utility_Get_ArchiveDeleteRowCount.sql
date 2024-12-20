CREATE PROC [Utility].[Get_ArchiveDeleteRowCount] AS

/*
###################################################################################################################
Proc Description: 
-------------------------------------------------------------------------------------------------------------------
Load Daily Row Counts of Landing TBOS Archive tables in Utility.ArchiveDeleteRowCount 
===================================================================================================================
Change Log:
-------------------------------------------------------------------------------------------------------------------
CHG0042840		Sagarika, Shankar		2023-04-19	New!
===================================================================================================================
Example:
-------------------------------------------------------------------------------------------------------------------
EXEC Utility.Get_ArchiveDeleteRowCount 
SELECT * FROM Utility.ProcessLog Where LogSource LIKE '%Get_ArchiveDeleteRowCount%' ORDER BY 1 DESC
SELECT TOP 1000 'Stage.ArchiveDeleteRowCount' TableName, * FROM Stage.ArchiveDeleteRowCount ORDER BY 1,2,3 
###################################################################################################################
*/

BEGIN

	BEGIN TRY

		DECLARE @Log_Source VARCHAR(100) = 'Utility.Get_ArchiveDeleteRowCount', @Log_Start_Date DATETIME2 (3) = SYSDATETIME(), @Load_Start_Date VARCHAR(10)  
		DECLARE @Log_Message VARCHAR(1000), @Row_Count BIGINT, @Trace_Flag BIT = 0 -- Testing
		EXEC    Utility.ToLog @Log_Source, @Log_Start_Date, 'Started APS Archive Delete Row Counts', 'I', NULL, NULL

		-- Marker for the most recent LND_TBOS load date
		SELECT @Load_Start_Date = CAST(CAST(DATEADD(DAY,-1,ISNULL(MAX(PostedDate),GETDATE())) AS DATE) AS VARCHAR) FROM  Stage.TP_Trips 
		DECLARE @Counter SMALLINT = 1, @SQL_Line VARCHAR(1000), @SQL VARCHAR(MAX) = '', @TablesCount SMALLINT, @APS_SQL VARCHAR(MAX)

		--::==================================================================================================
		--:: Daily RowCount script: Compare Daily row counts by LND_UpdateDate for each CDC table 
		--::==================================================================================================

		IF OBJECT_ID('tempdb..#ArchiveDeleteRowCount_SQL') IS NOT NULL DROP Table #ArchiveDeleteRowCount_SQL;
		CREATE Table #ArchiveDeleteRowCount_SQL WITH (HEAP, DISTRIBUTION = Replicate) AS 
		SELECT	ROW_NUMBER() OVER (ORDER BY TLP.DataBaseName,TLP.FullName) RN, CHAR(10) + 
				'SELECT CAST(LND_UpdateDate AS DATE) AS LND_UpdateDate,''' + TLP.DataBaseName + ''' DataBaseName,''' + TLP.FullName + ''' TableName, CAST(' + CAST(TLP.CDCFlag AS VARCHAR) + ' AS BIT) AS CDCFlag, CAST(' + CAST(TLP.ArchiveFlag AS VARCHAR) + ' AS BIT) AS ArchiveFlag, CAST(' + CASE WHEN HD.TableName IS NOT NULL THEN '1' ELSE '0' END + 'AS BIT) AS HardDeleteTableFlag, CAST(' + CASE WHEN ALT.TableName IS NOT NULL THEN '1' ELSE '0' END + ' AS BIT) AS ArchiveMasterListFlag, ' + 
			    'LND_UpdateType, ' + 
				'COUNT_BIG(1) Row_Count, CAST(SYSDATETIME() AS DATETIME2(3)) AS RowCountDate' + CHAR(10) + 
				'FROM LND_TBOS.' + TLP.FullName + CHAR(10) +  
				'WHERE LND_UpdateType  IN (''D'',''A'')' + CHAR(10) + 
				'AND LND_UpdateDate >= ''' + @Load_Start_Date + '''' + CHAR(10) +
				'GROUP BY ' + 'CAST(LND_UpdateDate AS DATE)'+',LND_UpdateType' + CHAR(10) + 
				'UNION ALL' + CHAR(10) AS SQL_Line    
		FROM Utility.TableLoadParameters TLP
		LEFT JOIN Utility.HardDeleteTable HD ON TLP.FullName = HD.TableName
		LEFT JOIN Utility.ArchiveMasterTableList ALT ON TLP.FullName = ALT.TableName
		WHERE TLP.Active = 1 AND TLP.FullName NOT IN ('Reporting.InvoiceDetail_Tunned','TranProcessing.NTTAHostBOSFileTracker','TollPlus.TpFileTracker')
		--AND TLP.FullName LIKE '%ACTIVITI%'

		SELECT @TablesCount = MAX(RN) FROM #ArchiveDeleteRowCount_SQL

		WHILE (@Counter <= @TablesCount)
		BEGIN

			SELECT @SQL_Line = SQL_Line 
			FROM #ArchiveDeleteRowCount_SQL M
			WHERE M.RN = @Counter

			SET @SQL = @SQL + CASE WHEN @Counter = @TablesCount THEN REPLACE(@SQL_Line,'UNION ALL','') ELSE @SQL_Line END

			SET @Counter += 1
		END

		SET @SQL = 'TRUNCATE TABLE Stage.ArchiveDeleteRowCount' + CHAR(10) + 'INSERT Stage.ArchiveDeleteRowCount' + CHAR(10) + @SQL
		IF @Trace_Flag = 1 EXEC Utility.LongPrint @SQL

		--:: Get Row Counts SQL
		EXEC (@SQL)
		SET  @Log_Message = 'Loaded A or D Row Counts for ' + CONVERT(VARCHAR,@TablesCount) + ' tables from the latest load into Stage.ArchiveDeleteRowCount ' 
		EXEC Utility.ToLog @Log_Source, @Log_Start_Date, @Log_Message, 'I', -1, @SQL
		
		--:: Load new A or D row counts
		INSERT Utility.ArchiveDeleteRowCount (LND_UpdateDate, DataBaseName, TableName, CDCFlag, ArchiveFlag, HardDeleteTableFlag, ArchiveMasterListFlag, LND_UpdateType, Row_Count, RowCountDate)
		SELECT LND_UpdateDate, DataBaseName, TableName, CDCFlag, ArchiveFlag, HardDeleteTableFlag, ArchiveMasterListFlag, LND_UpdateType, Row_Count, RowCountDate
		FROM Stage.ArchiveDeleteRowCount S 
		WHERE NOT EXISTS (SELECT 1 FROM Utility.ArchiveDeleteRowCount M WHERE M.LND_UpdateDate = S.LND_UpdateDate AND M.TableName = S.TableName AND M.LND_UpdateType = S.LND_UpdateType AND M.Row_Count = S.Row_Count)
		SET  @Log_Message = 'Loaded new A or D Row Counts for ' + CONVERT(VARCHAR,@TablesCount) + ' tables into Utility.ArchiveDeleteRowCount ' 
		EXEC Utility.ToLog @Log_Source, @Log_Start_Date, @Log_Message, 'I', -1, @SQL

		EXEC Utility.ToLog @Log_Source, @Log_Start_Date, 'Completed APS Archive Delete Row Counts', 'I', NULL, NULL
		
		-- Show results
		IF @Trace_Flag = 1 EXEC Utility.FromLog @Log_Source, @Log_Start_Date
		IF @Trace_Flag = 1 SELECT 'Stage.ArchiveDeleteRowCount' TableName, * FROM Stage.ArchiveDeleteRowCount ORDER BY 2,3,4 DESC

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
EXEC Utility.Get_ArchiveDeleteRowCount 
SELECT * FROM Utility.ProcessLog Where LogSource LIKE '%Get_ArchiveDeleteRowCount%' ORDER BY 1 DESC
SELECT TOP 1000 'Stage.ArchiveDeleteRowCount' TableName, * FROM Stage.ArchiveDeleteRowCount ORDER BY 1,2,3 

--===============================================================================================================
-- Dynamic SQL
--===============================================================================================================
SELECT CAST(LND_UpdateDate AS DATE) AS LND_UpdateDate,'TBOS' DataBaseName,'TollPlus.TP_Customer_Activities' TableName, CAST(1 AS BIT) AS CDCFlag, CAST(0 AS BIT) AS ArchiveFlag, CAST(0AS BIT) AS HardDeleteTableFlag, CAST(1 AS BIT) AS ArchiveMasterListFlag, LND_UpdateType, COUNT_BIG(1) Row_Count, CAST(SYSDATETIME() AS DATETIME2(3)) AS RowCountDate
FROM LND_TBOS_DEV.TollPlus.TP_Customer_Activities
WHERE LND_UpdateType  IN ('D','A')
AND LND_UpdateDate >= '2023-04-18'
GROUP BY CAST(LND_UpdateDate AS DATE),LND_UpdateType

*/

 
