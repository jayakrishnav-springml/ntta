CREATE PROC [Utility].[StartTableCDC] @TableName [VARCHAR](200) AS

/*
###################################################################################################################
Proc Description: 
-------------------------------------------------------------------------------------------------------------------
1. Log CDC Start
2. Clean up Stage Table for new CDC data flow
===================================================================================================================
Change Log:
-------------------------------------------------------------------------------------------------------------------
CHG0037837	Shankar		2020-12-16	New!
===================================================================================================================
Example:
-------------------------------------------------------------------------------------------------------------------
EXEC Utility.StartTableCDC @TableName = 'Finance.PaymentTxns'
EXEC Utility.FromLog 'Finance.PaymentTxns', 1
SELECT TOP 10 * FROM Utility.ProcessLog ORDER BY 1 DESC
###################################################################################################################
*/

BEGIN

	BEGIN TRY
		--:: DEBUG
		--DECLARE @TableName VARCHAR(200) = 'Finance.PaymentTxns'

		DECLARE @StageTableName VARCHAR(200), @SQL VARCHAR(8000), @Trace_Flag BIT = 0 -- Testing
		
		SET @TableName = REPLACE(REPLACE(@TableName,'[',''),']','')

		SELECT	@StageTableName	= StageTableName
		FROM	Utility.TableLoadParameters 
		WHERE	FullName  = @TableName

		SELECT @SQL = '

		DECLARE @Log_Source VARCHAR(100) = ''' + @TableName + ''' + '' - StartTableCDC'', @Log_Start_Date DATETIME2 (3) = SYSDATETIME(), @Log_Message VARCHAR(1000) 

		--=============================================================================================================
		--:1: Log CDC Start
		--=============================================================================================================

		DECLARE @LND_Row_Count BIGINT = 0, @Last_LND_UpdateDate VARCHAR(23) = ''''

		SELECT	@LND_Row_Count = COUNT_BIG(1), @Last_LND_UpdateDate = CONVERT(VARCHAR(23),MAX(LND_UpdateDate),121)				
		FROM	' + @TableName + ' 

		SET @Log_Message = ''SSIS CDC LOAD STARTED. Landing Table Row Count '' + CONVERT(VARCHAR, ISNULL(@LND_Row_Count,0)) + ''. Last Loaded Date '' + ISNULL(CONVERT(VARCHAR(23),@Last_LND_UpdateDate,121),''NULL'')   

		EXEC Utility.ToLog @Log_Source, @Log_Start_Date, @Log_Message,  ''I'', @LND_Row_Count, NULL

		--=============================================================================================================
		--:2: Clean up Stage Table for new CDC data flow
		--=============================================================================================================

		TRUNCATE TABLE ' + @StageTableName + '

		SET @Log_Message = ''Truncated Stage Table ' + @StageTableName + '''
		EXEC Utility.ToLog @Log_Source, @Log_Start_Date, @Log_Message,  ''I'', NULL, NULL

		--:: Return output from dynamic SQL run
		SELECT @Log_Start_Date AS CDC_StartDate, @Last_LND_UpdateDate AS Start_LND_UpdateDate, ISNULL(@LND_Row_Count,0) AS StartRowCount
		'

		IF @Trace_Flag = 1 PRINT @SQL
		EXEC (@SQL)

	END	TRY
	
	BEGIN CATCH
		
		DECLARE @Log_Source VARCHAR(100) = ISNULL(@TableName,'Utility.StartTableCDC'), @Log_Start_Date DATETIME2 (3) = SYSDATETIME(), @Error_Message VARCHAR(MAX) = ERROR_MESSAGE() 
		EXEC    Utility.ToLog @Log_Source, @Log_Start_Date, @Error_Message, 'E', NULL, NULL;
		EXEC	Utility.FromLog @Log_Source, @Log_Start_Date;
		THROW;  -- Rethrow the error!
	
	END CATCH

END

/*
--===============================================================================================================
-- DEVELOPER TESTING ZONE to thoroughly test the code for various scenarios
--===============================================================================================================
EXEC Utility.StartTableCDC @TableName = 'TollPlus.TP_Image_Review_Result_Images'
EXEC Utility.FromLog 'StartTableCDC', 1

--===============================================================================================================
-- USEFUL DATA VALIDATION SCRIPTS for post prod move monitoring or for others to not reinvent the wheel
--===============================================================================================================
SELECT	Total_Row_Count = COUNT_BIG(1), 
		INSERTS = SUM(CASE WHEN LND_UpdateType = 'I' THEN 1 ELSE 0 END),
		UPDATES = SUM(CASE WHEN LND_UpdateType = 'U' THEN 1 ELSE 0 END),
		DELETES = SUM(CASE WHEN LND_UpdateType = 'D' THEN 1 ELSE 0 END)
FROM	Stage.PaymentTxns  

*/


