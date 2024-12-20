CREATE PROC [Utility].[FinishTableCDC] @TableName [VARCHAR](200),@CDC_StartDate [VARCHAR](23) AS
/*
###################################################################################################################
Proc Description: 
-------------------------------------------------------------------------------------------------------------------
Apply data changes in Stage table to main landing table. 
===================================================================================================================
Change Log:
-------------------------------------------------------------------------------------------------------------------
CHG0037837	Andy, Shankar	    12/18/2020	New!
CHG0041190	Shekhar, Sagarika	07/17/2022	Added new If statement for Archive Tables!
CHG0042607  Shekhar, Sagarika   02/27/2023  Restored to previous version as Archival Changes D -> A have been 
                                            moved to SSIS
CHG0042840  Shankar				4/20/2023	Log Archive row count
===================================================================================================================
Example:
-------------------------------------------------------------------------------------------------------------------
SELECT LND_UpdateType, COUNT(1) RC FROM Stage.PaymentTxns GROUP BY LND_UpdateType ORDER BY 2 DESC
EXEC Utility.FinishTableCDC @TableName = '[tollplus].[TP_Customer_Vehicles]', @CDC_StartDate = '7/13/2022'
EXEC Utility.FromLog 'Finance.PaymentTxns', 1
###################################################################################################################
*/

BEGIN
	--:: DEBUG
	--DECLARE @TableName VARCHAR(200) = 'Finance.PaymentTxns'

	SET @TableName = REPLACE(REPLACE(@TableName,'[',''),']','')
	DECLARE @LogMessage VARCHAR(4000), @Log_Source VARCHAR(100) = @TableName + ' - FinishTableCDC', @StartDate DATETIME2(3) = SYSDATETIME()
	DECLARE @Table VARCHAR(100), @StageTableName VARCHAR(200)
	DECLARE @DeleteSQL VARCHAR(MAX), @InsertSQL VARCHAR(MAX)
	DECLARE @Step VARCHAR(30), @Trace_Flag BIT = 0 -- Testing
	DECLARE @SQL VARCHAR(MAX)

	SELECT	 @Table				= TableName
			,@StageTableName	= StageTableName
			,@InsertSQL			= InsertSQL			
			,@DeleteSQL			= DeleteSQL			
	FROM	Utility.TableLoadParameters 
	WHERE	FullName  = @TableName

	BEGIN TRY

		SET @Step = 'Delete changed rows'

		IF @Trace_Flag = 1 EXEC Utility.LongPrint @DeleteSQL
		EXECUTE (@DeleteSQL); 

		EXEC Utility.ToLog @Log_Source, @CDC_StartDate, 'Deleted changed rows', 'I',-1,NULL

		SET @Step = 'Insert changed rows '

		IF @Trace_Flag = 1 EXEC Utility.LongPrint @InsertSQL
		EXECUTE (@InsertSQL); 

		EXEC Utility.ToLog @Log_Source, @CDC_StartDate, 'Inserted changed rows', 'I',-1,NULL

		SET @Step = 'Update statistics'
		SET @SQL = 'UPDATE STATISTICS ' + @TableName
		IF @Trace_Flag = 1 EXEC Utility.LongPrint @SQL
		EXECUTE (@SQL)

		EXEC Utility.ToLog @Log_Source, @CDC_StartDate, 'Updated statistics', 'I',NULL,NULL

		SET @Step = 'Log CDC Finish'
		SELECT @SQL = '
		DECLARE @Log_Source VARCHAR(100) = ''' + @TableName + ' - FinishTableCDC''
		DECLARE @Log_Message VARCHAR(1000)

		--=============================================================================================================
		--:2: Log CDC Finish
		--=============================================================================================================
		DECLARE @Stage_Row_Count BIGINT, @INSERTS BIGINT, @UPDATES BIGINT, @DELETES BIGINT, @ARCHIVES BIGINT
		DECLARE @LND_Row_Count BIGINT, @Last_LND_UpdateDate VARCHAR(23)

		SELECT	@Stage_Row_Count = COUNT_BIG(1), 
				@INSERTS = SUM(CASE WHEN LND_UpdateType = ''I'' THEN 1 ELSE 0 END),
				@UPDATES = SUM(CASE WHEN LND_UpdateType = ''U'' THEN 1 ELSE 0 END),
				@DELETES = SUM(CASE WHEN LND_UpdateType = ''D'' THEN 1 ELSE 0 END),
				@ARCHIVES = SUM(CASE WHEN LND_UpdateType = ''A'' THEN 1 ELSE 0 END)
		FROM	' + @StageTableName + '

		SET @Log_Message = ''Stage Table Row Count '' + CONVERT(VARCHAR, ISNULL(@Stage_Row_Count,0)) + ''. INSERTS: '' + CONVERT(VARCHAR, ISNULL(@INSERTS,0)) + '', UPDATES: '' + CONVERT(VARCHAR, ISNULL(@UPDATES,0)) + '', DELETES: '' + CONVERT(VARCHAR, ISNULL(@DELETES,0))  + '', ARCHIVES: '' + CONVERT(VARCHAR, ISNULL(@ARCHIVES,0))

		EXEC Utility.ToLog @Log_Source, ''' + @CDC_StartDate + ''', @Log_Message,  ''I'', @Stage_Row_Count, NULL

		SELECT	@LND_Row_Count = COUNT_BIG(1),
				@Last_LND_UpdateDate = CONVERT(VARCHAR(23),MAX(LND_UpdateDate),121)
		FROM	' + @TableName + ' 

		SET @Log_Message = ''SSIS CDC LOAD FINISHED. Landing Table Row Count '' + CONVERT(VARCHAR, ISNULL(@LND_Row_Count,0)) + ''. Last Loaded Date '' + ISNULL(CONVERT(VARCHAR(23),@Last_LND_UpdateDate,121),''NULL'')

		EXEC Utility.ToLog @Log_Source, ''' + @CDC_StartDate + ''', @Log_Message,  ''I'', @LND_Row_Count, NULL
		'
		IF @Trace_Flag = 1 PRINT @SQL
		EXEC (@SQL)

		END	TRY	
		BEGIN CATCH
			SELECT @LogMessage = @Step + ' failed. Error Info: ' + ERROR_MESSAGE()
			EXEC  Utility.ToLog @Log_Source, @StartDate, @LogMessage, 'E',NULL,@SQL
			IF @Trace_Flag = 1 PRINT @LogMessage;
			THROW;  -- Rethrow the error!
		END CATCH

END

/*
--===============================================================================================================
-- !!! DEVELOPER TESTING ZONE to thoroughly test the code for various scenarios !!!
--===============================================================================================================
SELECT * FROM Utility.ProcessLog ORDER BY 1 DESC 

*/


