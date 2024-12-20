CREATE PROC [Utility].[LandingDataTransferAfterSSIS] @TableList [VARCHAR](4000),@LoadProcessID [INT] AS
/*
IF OBJECT_ID ('Utility.LandingDataTransferAfterSSIS', 'P') IS NOT NULL DROP PROCEDURE Utility.LandingDataTransferAfterSSIS  
GO

###################################################################################################################
Example:
-------------------------------------------------------------------------------------------------------------------
EXEC Utility.LandingDataTransferAfterSSIS '[Finance].[Overpayments]', 0
EXEC Utility.LandingDataTransferAfterSSIS '', 0
EXEC Utility.FromLog '', 1

===================================================================================================================
Proc Description: 
-------------------------------------------------------------------------------------------------------------------
This proc used as a second step for SSIS load process and moving all loaded changes from Stage tables to Production tables. It can call other procs.


@TableList - can be epmty or having table list, devided by comma. Every table should consist of Schema name and Table name.
@LoadProcessID is used to parallelise load process - Do not use it for Full load - can stuck and block everything because of Schema tranfer object block!!!
===================================================================================================================
Change Log:
-------------------------------------------------------------------------------------------------------------------
CHG0037837	Andy		12/31/2020		New!
CHG0038290	Andy		3/3/2021		To keep Deleted Rows while doing full load in Landing
CHG0043566	Sagarika	8/23/2023		Preserve Archived Rows while doing full load in Landing
CHG0043621	Shankar		9/17/2023		1. Organized all the sequence of steps and added ProcessLog for each step to help 
										   with prod issue research. Removed all dead code.
										2. Alert main table data loss if stage table has 0 I rows and exit
										3. If deleted/archived rows are already present in the full load stage table, they must
										   be inserted by previous Landing Data Transfer run which either failed or stopped.
										   Reinserting them again will only bring duplicate rows.
										4. Drop any existing Stats on stage table before creating all Stats. Create Statistics 
										   fail if there is already an existing Statistic with the same name on the table.
										5. Fixed blank INDEX string in the output of Utility.Get_CreateEmptyCopy_SQL resulting in error.
										6. Backup SSISLoadCheck data before deleting for research. 
###################################################################################################################
*/

BEGIN
	/*====================================== TESTING =======================================================================*/
	--DECLARE @TableList VARCHAR(4000), @LoadProcessID INT 
	/*====================================== TESTING =======================================================================*/

	IF @TableList IS NULL SET @TableList = ''
	IF @LoadProcessID IS NULL SET @LoadProcessID = 0

	SET @TableList = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(@TableList,'[',''),']',''),' ',''),CHAR(9),''),CHAR(13),'')
	IF LEN(@TableList) > 0
		SET @TableList = ',' + @TableList + ','

	DECLARE @StartDate DATETIME2(3) = SYSDATETIME(), @LogDate DATETIME2(3) = SYSDATETIME()--= DATEADD(DAY,-5,@StartDateProc) 
	DECLARE @NUM_OF_COLUMNS	INT, @INDICAT INT = 1, @Row_Count BIGINT = 0, @RowCnt BIGINT, @Step VARCHAR(250), @Errors BIT, @TableCount BIGINT = 0
	DECLARE @SchemaName	VARCHAR(30), @TableName VARCHAR(100), @MainTableName VARCHAR(130), @StageTableName VARCHAR(130), @NewTableName VARCHAR(130), @UpdatedDateColumn VARCHAR(30)
	DECLARE @DistributionString	VARCHAR(100), @UID_Columns VARCHAR(800), @ColumnsString VARCHAR(8000), @WhereString VARCHAR(8000), @SQL_NEW_SET VARCHAR(MAX)
	DECLARE @StatsSQL VARCHAR(8000), @IndexString VARCHAR(8000), @DeleteSQL VARCHAR(MAX), @InsertSQL VARCHAR(MAX), @RenameSQL VARCHAR(MAX)
	DECLARE @RunAfterProc VARCHAR(MAX), @UpdateProc	VARCHAR(MAX), @UseUpdatedDate BIT = 1, @UsePartition BIT = 0
	DECLARE @Nsql NVARCHAR(MAX), @ParmDefinition NVARCHAR(1000), @Query VARCHAR(MAX), @IsFullLoad BIT = 0
	DECLARE @LogMessage VARCHAR(4000), @Trace_Flag BIT = 1 -- Testing

	SELECT @LogMessage = 'Started for ' + CASE WHEN @TableList = '' THEN 'all tables' ELSE 'table list: ' + @TableList END + CASE WHEN @LoadProcessID = 0 THEN ' for all ProcessIDs' ELSE ' for ProcessID = ' + CAST(@LoadProcessID AS CHAR(1)) END

	EXEC Utility.ToLog 'Utility.LandingDataTransferAfterSSIS', @LogDate, @LogMessage, 'I',NULL,NULL

	IF OBJECT_ID('tempdb..#LoadTable') IS NOT NULL DROP TABLE #LoadTable
	/*====================================== TESTING =======================================================================*/
	--SELECT * FROM Utility.[TableLoadParameters]
	/*====================================== TESTING =======================================================================*/

	CREATE TABLE #LoadTable WITH (HEAP, DISTRIBUTION = REPLICATE) AS
	WITH CTE_LAST_LOADS AS
	(	
		-- Need find those tables, where last load ssis is finished but Load after ssis is not done yet
		--	It's only one row for each table could be with LoadStep = 'S:3'
		SELECT 
			LoadSource, LoadDate, Row_Count,CASE WHEN LoadInfo LIKE 'Step 2: SSIS Load finished' THEN 1 ELSE 0 END AS IsFullLoad
		FROM Utility.SSISLoadCheck
		WHERE LoadStep = 'S:3' AND Row_Count > 0
	)
	, CTE_TableLoadParameters AS
	(	
		SELECT 
			L.LoadDate, L.Row_Count, T.[SchemaName], T.TableName, T.FullName, T.StageTableName, T.UseUpdatedDate, T.UID_Columns, T.UsePartition, ISNULL(T.RunAfterProc, '') AS RunAfterProc, T.DistributionString,
			T.StatsSQL, T.DeleteSQL, T.InsertSQL, T.ColumnsString, T.WhereString, T.RenameSQL, ISNULL(T.UpdateProc, '') AS UpdateProc, T.RowCnt, T.IndexString, T.UpdatedDateColumn, L.IsFullLoad
			, ROW_NUMBER() OVER (PARTITION BY L.LoadSource ORDER BY L.LoadDate DESC) FilterRN -- Should go only one
		FROM CTE_LAST_LOADS L
		JOIN Utility.[TableLoadParameters] T ON LTRIM(RTRIM(L.LoadSource)) = T.FullName -- LIKE T.FullName + '%' --CHARINDEX(T.FullName, L.LoadSource) > 0
		WHERE (@TableList = '' OR @TableList LIKE '%,' + T.FullName + ',%') AND (@LoadProcessID = 0 OR T.LoadProcessID = @LoadProcessID) AND T.Active = 1
	)
	SELECT 
		LoadDate, Row_Count, [SchemaName], TableName, FullName, StageTableName, UseUpdatedDate, UID_Columns, UsePartition, RunAfterProc, DistributionString,
		StatsSQL, DeleteSQL, InsertSQL, ColumnsString, WhereString, RenameSQL, UpdateProc, RowCnt, IndexString, UpdatedDateColumn, IsFullLoad
		, ROW_NUMBER() OVER (ORDER BY FullName) RN
	FROM CTE_TableLoadParameters
	WHERE FilterRN = 1


	/*====================================== TESTING =======================================================================*/
	--SELECT * FROM #LoadTable
	/*====================================== TESTING =======================================================================*/


	SELECT @NUM_OF_COLUMNS = MAX(RN) FROM #LoadTable
	WHILE (@INDICAT <= @NUM_OF_COLUMNS)
	BEGIN
		SELECT 
			@SchemaName			 = [SchemaName]		
			,@TableName			 = TableName			
			,@MainTableName			 = FullName			
			,@IsFullLoad		 = IsFullLoad			
			,@Row_Count			 = Row_Count			
			,@RowCnt			 = RowCnt			
			,@StageTableName	 = StageTableName		
			,@NewTableName		 = FullName + '_New'
			,@UID_Columns		 = UID_Columns	
			,@UsePartition		 = UsePartition	
			,@ColumnsString		 = ColumnsString	
			,@DistributionString = DistributionString	
			,@IndexString		 = IndexString	
			,@WhereString		 = WhereString		
			,@StatsSQL			 = StatsSQL			
			,@DeleteSQL			 = DeleteSQL			
			,@InsertSQL			 = InsertSQL			
			,@UseUpdatedDate	 = CASE WHEN IsFullLoad = 1 THEN 0 ELSE UseUpdatedDate END
			,@UpdatedDateColumn	 = UpdatedDateColumn	
			,@UpdateProc		 = UpdateProc		
			,@RunAfterProc		 = RunAfterProc			
		FROM #LoadTable WHERE RN = @INDICAT

		--IF @Trace_Flag = 1 -- Let's see this all the time, not only when we test it.
		PRINT 'Loading table: ' + @MainTableName

		EXEC Utility.ToLog @MainTableName, @StartDate, 'Step 3: Load after SSIS Started', 'I',NULL,NULL
		SELECT @StartDate = SYSDATETIME(), @Errors = 0

		IF LEN(@UpdateProc) > 0
		BEGIN
			IF @Trace_Flag = 1 PRINT 'Update proc found - using ' + @UpdateProc
			SELECT @ParmDefinition = N'@TableName VARCHAR(100),@Row_Count BIGINT, @UID_Columns VARCHAR(800),@IsFullLoad BIT', @Nsql = CASE WHEN CHARINDEX('EXEC',@UpdateProc) = 0 THEN N'EXECUTE ' ELSE N'' END + @UpdateProc

			BEGIN TRY
				EXECUTE sp_executesql @Nsql, @ParmDefinition, @TableName = @MainTableName, @Row_Count = @Row_Count, @UID_Columns = @UID_Columns, @IsFullLoad = @IsFullLoad
			END	TRY	
			BEGIN CATCH
				SELECT @Errors = 1, @LogMessage = 'Step 3 Failed: UpdateProc load: ' + ERROR_MESSAGE()
				EXEC  Utility.ToLog @MainTableName, @StartDate, @LogMessage, 'E', NULL, @Nsql
				IF @Trace_Flag = 1 PRINT @LogMessage
			END CATCH

		END
		ELSE
		BEGIN
			-- No UPDATEDDATE column - reload whole table then only rename it from stage to main table and back
			IF @Trace_Flag = 1 PRINT 'Using RENAME for full load' 
			SET @Step = 'Step 3 Failed: SQL RENAME: '
			BEGIN TRY
				EXEC Utility.ToLog @MainTableName, @StartDate, 'Step 3: RENAME load started', 'I',NULL,NULL

				-- 1. Pre-screening of row counts in Stage and Main table
				SET @Step = 'Step 3 Failed: Pre-screening stage table for 0 Inserted rows: '
				DECLARE @MainTableRowCount_I_U BIGINT = 0, @MainTableRowCount_D_A BIGINT = 0, @StageTableRowCount_I BIGINT = 0, @StageTableRowCount_D_A BIGINT = 0
				SET @ParmDefinition = N'@RowCount BIGINT OUTPUT'
				SET @Nsql = 'SELECT @RowCount = COUNT_BIG(1) FROM ' + @StageTableName + ' (NOLOCK) WHERE LND_UpdateType NOT IN (''D'',''A'')' -- 0 rows? It's an empty stage table! Danger! Do not rename it as main table!! Stage table initially contains only "I" rows after full load SSIS run
				EXECUTE sp_executesql @Nsql, @ParmDefinition, @RowCount = @StageTableRowCount_I OUTPUT  
				SET @Nsql = 'SELECT @RowCount = COUNT_BIG(1) FROM ' + @StageTableName + ' (NOLOCK) WHERE LND_UpdateType IN (''D'',''A'')' 
				EXECUTE sp_executesql @Nsql, @ParmDefinition, @RowCount = @StageTableRowCount_D_A OUTPUT  
				SET @Nsql = 'SELECT @RowCount = COUNT_BIG(1) FROM ' + @MainTableName  + ' (NOLOCK) WHERE LND_UpdateType NOT IN (''D'',''A'')'
				EXECUTE sp_executesql @Nsql, @ParmDefinition, @RowCount = @MainTableRowCount_I_U OUTPUT  
				SET @Nsql = 'SELECT @RowCount = COUNT_BIG(1) FROM ' + @MainTableName  + ' (NOLOCK) WHERE LND_UpdateType IN (''D'',''A'')'
				EXECUTE sp_executesql @Nsql, @ParmDefinition, @RowCount = @MainTableRowCount_D_A OUTPUT  
				
				IF @Trace_Flag = 1 SELECT @StageTableRowCount_I [@StageTableRowCount_I], @StageTableRowCount_D_A [@StageTableRowCount_D_A], @MainTableRowCount_I_U [@MainTableRowCount_I_U], @MainTableRowCount_D_A [@MainTableRowCount_D_A]
				SELECT @LogMessage = '1. Stage table ' + @StageTableName + ' has ' + CONVERT(VARCHAR,@StageTableRowCount_I) + ' I rows and ' + CONVERT(VARCHAR,@StageTableRowCount_D_A) + 
										' D/A rows. Main table ' + @MainTableName + ' has ' + CONVERT(VARCHAR,@MainTableRowCount_I_U) + ' I/U rows and ' + CONVERT(VARCHAR,@MainTableRowCount_D_A) + ' D/A rows.';
				EXEC  Utility.ToLog @MainTableName, @StartDate, @LogMessage, 'I',NULL,NULL
				IF @Trace_Flag = 1 PRINT @LogMessage

				--If Stage Table has 0 "I" rows, stop making it as the Main Table. No way! Abort... Abort... :-(
				IF @StageTableRowCount_I = 0 
				BEGIN
					SELECT @LogMessage = '1. DATA LOSS PREVENTION ALERT!! ABORT LANDING DATA TRANSFER: Stage table ' + @StageTableName + ' has ' + CONVERT(VARCHAR,@StageTableRowCount_I) + ' I rows and ' + CONVERT(VARCHAR,@StageTableRowCount_D_A) + 
										 ' D/A rows. Main table ' + @MainTableName + ' has ' + CONVERT(VARCHAR,@MainTableRowCount_I_U) + ' I/U rows and ' + CONVERT(VARCHAR,@MainTableRowCount_D_A) + ' D/A rows.';
					THROW 51000, @LogMessage, 1; -- CATCH me, if you can!
				END

				-- 2. Copy deleted and archived rows from the main table into stage table before table rename
				-- This step need to keep deleted and archived rows we got from CDC - in full load they all will be removed
				-- We just insert them all to stage from main table - it's the fastest way.
				-- If stage table already have D and A rows inserted by the previous run which stopped or failed in the middle,
				-- do NOT reinsert D and A rows from the main table again to prevent duplicate rows and ensure restartability of the proc.

				DECLARE @AddDeletedArchivedRowsSQL VARCHAR(300) = 'INSERT INTO ' + @StageTableName + '
				SELECT * FROM ' + @MainTableName + '
				WHERE LND_UpdateType IN (''D'',''A'') 
				AND NOT EXISTS (SELECT 1 FROM ' + @StageTableName + ' WHERE LND_UpdateType IN (''D'',''A''))'
				
				SET @Query = @AddDeletedArchivedRowsSQL
				IF @Trace_Flag = 1 EXEC Utility.LongPrint @AddDeletedArchivedRowsSQL
				EXECUTE (@AddDeletedArchivedRowsSQL)

				SELECT @LogMessage = '2. Inserted soft Deleted and Archived rows from ' + @MainTableName + ' into ' + @StageTableName
				EXEC  Utility.ToLog @MainTableName, @StartDate, @LogMessage, 'I',-1,-1
				IF @Trace_Flag = 1 PRINT @LogMessage

				-- 3. Drop any existing Statistics on the stage table as it should not should not have any statistics 
				DECLARE @DropStatsSQL VARCHAR(500)
				EXEC Utility.Get_DropStatistics_SQL @StageTableName, @Params_In_SQL_Out = @DropStatsSQL OUTPUT 
				IF @DropStatsSQL != ''
				BEGIN
					SET @Query = @DropStatsSQL
					SET @Step = 'Step 3 Failed: SQL Drop Stats: '
					EXECUTE(@DropStatsSQL)
					SELECT @LogMessage = '3. Dropped Statitics on the stage table '+ @StageTableName + ' before recreating all Statistics on stage table in the next step and rename it as main table. Saved the day!'
					EXEC  Utility.ToLog @MainTableName, @StartDate, @LogMessage, 'I',NULL,@DropStatsSQL
					IF @Trace_Flag = 1 PRINT @LogMessage
				END  
				ELSE
				BEGIN
					SELECT @LogMessage = '3. No Statitics to drop on the stage table '+ @StageTableName + ' before creating all Statistics on stage table in the next step and rename it as main table'
					EXEC  Utility.ToLog @MainTableName, @StartDate, @LogMessage, 'I',NULL,@DropStatsSQL
					IF @Trace_Flag = 1 PRINT @LogMessage
				END

				-- 4. Create Statistics on the stage table
				IF @StatsSQL != ''
				BEGIN
					SET @Step = 'Step 3 Failed: SQL Create Stats: '
					SET @Query = @StatsSQL
					IF @Trace_Flag = 1 EXEC Utility.LongPrint @StatsSQL
					EXECUTE (@StatsSQL)
					
					SELECT @LogMessage = '4. Created Statitics on the stage table '+ @StageTableName
					EXEC  Utility.ToLog @MainTableName, @StartDate, @LogMessage, 'I',NULL,@StatsSQL
					IF @Trace_Flag = 1 PRINT @LogMessage
				END
				ELSE
				BEGIN
					SELECT @LogMessage = '4. No Statitics to create on the stage table '+ @StageTableName + ' based on ' + @MainTableName
					EXEC  Utility.ToLog @MainTableName, @StartDate, @LogMessage, 'I',NULL,@StatsSQL
					IF @Trace_Flag = 1 PRINT @LogMessage
				END

				-- 5. Table swap
				SET @Step = 'Step 3 Failed: SQL Transfer Object: '
				SET @RenameSQL = 'NoPrint'
				EXEC Utility.Get_TransferObject_SQL @StageTableName, @MainTableName, @RenameSQL OUTPUT
				SET @Query = @RenameSQL
				IF @Trace_Flag = 1 EXEC Utility.LongPrint @RenameSQL
				EXECUTE (@RenameSQL)
				
				SELECT @LogMessage = '5. Renamed ' + @StageTableName + ' to ' + @MainTableName
				EXEC  Utility.ToLog @MainTableName, @StartDate, @LogMessage, 'I',NULL,@RenameSQL
				IF @Trace_Flag = 1 PRINT @LogMessage

				-- 6. After rename we should create new stage table
				SET @Step = 'Step 3 Failed: SQL Create Empty Copy: '
				SET @Nsql = 'NoPrint'
				EXEC Utility.Get_CreateEmptyCopy_SQL @MainTableName, @StageTableName, @Nsql OUTPUT
				SET @Query = @Nsql
				IF @Trace_Flag = 1 EXEC Utility.LongPrint @Nsql
				EXEC (@Nsql)

				SELECT @LogMessage = '6. Created an empty copy of ' + @MainTableName + ' as ' + @StageTableName
				EXEC  Utility.ToLog @MainTableName, @StartDate, @LogMessage, 'I',NULL,NULL
				IF @Trace_Flag = 1 PRINT @LogMessage

				-- 7. Now if no errors we should delete all steps from SSIS load check table so next time it will load again fully (not full load - just all theads)
				SET @Step = 'Step 3 Failed: SQL Delete SSISLoadCheck rows for ' + @MainTableName + ': '
				INSERT Utility.SSISLoadCheckLog (LoadDate, LoadSource, LoadStep, LoadInfo, Row_Count, LND_UpdateDate)
				SELECT LoadDate, LoadSource, LoadStep, LoadInfo, Row_Count, SYSDATETIME() LND_UpdateDate  FROM Utility.SSISLoadCheck WHERE LoadSource = @MainTableName
				DELETE FROM Utility.SSISLoadCheck WHERE LoadSource = @MainTableName
				
				-- We are not empty Stage table to have possibility to see what was loaded last time - it will be truncated in SSIS
				SELECT @LogMessage = '7. Deleted Utility.SSISLoadCheck rows for the next full load of ' + @MainTableName + ' after saving them in Utility.SSISLoadCheckLog for future reference'
				EXEC  Utility.ToLog @MainTableName, @StartDate, @LogMessage, 'I',NULL,NULL
				IF @Trace_Flag = 1 PRINT @LogMessage

				EXEC Utility.ToLog @MainTableName, @StartDate, 'Step 3: Load afetr SSIS Finished', 'I', NULL, NULL -- Keep this spelling mistake "afetr" as this string is used in some places

				-- 8. Post-processing procedure run. Currently there is no "use case" of any table so far where there is need for post-processing after Landing Data Transfer is done. NOT IN USE.
				IF LEN(@RunAfterProc) > 0
				BEGIN
					IF @Trace_Flag = 1 PRINT 'Run after load proc found - using ' + @RunAfterProc
		
					SELECT @ParmDefinition = N'@TableName VARCHAR(100), @UID_Columns VARCHAR(800)', @Nsql = CASE WHEN CHARINDEX('EXEC',@RunAfterProc) = 0 THEN N'EXECUTE ' ELSE N'' END + @RunAfterProc

					BEGIN TRY
						EXECUTE sp_executesql @Nsql, @ParmDefinition,@TableName = @MainTableName,@UID_Columns = @UID_Columns
					END	TRY	
					BEGIN CATCH
						SELECT @LogMessage = 'LandingDataTransferAfterSSIS Failed:' + ERROR_MESSAGE()
						EXEC  Utility.ToLog @MainTableName, @StartDate, @LogMessage, 'E', NULL, @Nsql
						IF @Trace_Flag = 1 PRINT @LogMessage
					END CATCH
				END

			END	TRY	
			BEGIN CATCH
				SELECT @Errors = 1, @LogMessage = @Step + ERROR_MESSAGE()
				EXEC  Utility.ToLog @MainTableName, @StartDate, @LogMessage, 'E', NULL, @Query
				IF @Trace_Flag = 1 PRINT @LogMessage
			END CATCH
		END 

		SET @INDICAT += 1
	END -- WHILE (@INDICAT <= @NUM_OF_COLUMNS)

	EXEC Utility.ToLog 'Utility.LandingDataTransferAfterSSIS', @LogDate, 'Finished', 'I',NULL,NULL


END

/*
--===============================================================================================================
-- !!! DEVELOPER TESTING ZONE to thoroughly test the code for various scenarios !!!
--===============================================================================================================


SELECT 
	* --LoadSource, LoadDate, Row_Count
FROM Utility.SSISLoadCheck
WHERE LoadStep = 'S:3' AND Row_Count > 0
ORDER BY LoadDate DESC

SELECT T.FullName, S.LoadSource FROM Utility.TableLoadParameters T
LEFT JOIN Utility.SSISLoadCheck S ON S.LoadSource = T.FullName AND S.LoadStep = 'S:3' AND S.Row_Count > 0
WHERE T.Active = 1 AND S.LoadSource IS NULL
ORDER by TableName


*/

