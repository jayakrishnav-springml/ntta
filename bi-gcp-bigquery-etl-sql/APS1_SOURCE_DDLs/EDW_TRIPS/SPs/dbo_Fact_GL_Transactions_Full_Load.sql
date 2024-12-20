CREATE PROC [dbo].[Fact_GL_Transactions_Full_Load] AS

/*
###################################################################################################################
Proc Description: 
-------------------------------------------------------------------------------------------------------------------
Load dbo.Fact_GL_Transactions table. 
===================================================================================================================
Change Log:
-------------------------------------------------------------------------------------------------------------------
CHG0037838 	Arun		2020-11-01	New!
CHG0038040  Arun Krishna 2021-01-27 -- Added Delete Flag 


===================================================================================================================
Example:
-------------------------------------------------------------------------------------------------------------------
EXEC dbo.Fact_GL_Transactions_Full_Load

EXEC Utility.FromLog 'dbo.Fact_GL_Transactions', 1
SELECT TOP 100 'dbo.Fact_GL_Transactions' Table_Name, * FROM dbo.Fact_GL_Transactions ORDER BY 2
###################################################################################################################
*/
BEGIN
	BEGIN TRY

				DECLARE @Log_Source VARCHAR(100) = 'dbo.Fact_GL_Transactions_Full_Load',@Log_Start_Date DATETIME2(3) = SYSDATETIME();
				DECLARE @Log_Message VARCHAR(1000),@Row_Count BIGINT,@Trace_Flag BIT = 0; -- Testing
				EXEC    Utility.ToLog @Log_Source, @Log_Start_Date, 'Started full load', 'I', NULL, NULL;

				--=============================================================================================================
				-- Load dbo.Fact_GL_Transactions
				--=============================================================================================================
				IF OBJECT_ID('dbo.Fact_GL_Transactions_NEW') IS NOT NULL DROP TABLE dbo.Fact_GL_Transactions_NEW;
				CREATE TABLE dbo.Fact_GL_Transactions_NEW  WITH (CLUSTERED INDEX ( [GL_TxnID] DESC ), DISTRIBUTION = HASH([GL_TxnID])) 
				AS
				SELECT 
				 Gl_TxnID
				,PostingDate
				,PostingDate_yyyymm
				,CustomerID
				,TxnTypeID
				,BusinessProcessID
				,LinkID
				,LinkSourceName
				,TxnDate
				,TxnAmount
				,IsContra
				,[Description] AS Description
				,NULL AS RequestID
				,BusinessUnitId
				,CreatedDate
				,CreatedUser
				,UpdatedDate
				,UpdatedUser
				,CAST(CASE WHEN LND_UpdateType = 'D' THEN 1 ELSE 0 END AS BIT) DeleteFlag
				,LND_UpdateDate
				,CAST(SYSDATETIME() AS DATETIME2(3)) AS EDW_UpdateDate
				FROM LND_TBOS.Finance.GL_Transactions 
				WHERE LND_UpdateType <> 'D'

				OPTION (LABEL = 'dbo.Fact_GL_Transactions_NEW Load');;;
		
				SET  @Log_Message = 'Loaded dbo.Fact_GL_Transactions_NEW';
				EXEC Utility.ToLog @Log_Source,@Log_Start_Date,@Log_Message,'I',-1,NULL;

				-- Table swap!
				EXEC Utility.TableSwap 'dbo.Fact_GL_Transactions_NEW', 'dbo.Fact_GL_Transactions';

				EXEC Utility.ToLog @Log_Source,@Log_Start_Date,'Completed full load','I',NULL,NULL;

				-- Show results
				IF @Trace_Flag = 1
					EXEC Utility.FromLog @Log_Source, @Log_Start_Date;
				IF @Trace_Flag = 1
					SELECT TOP 1000
						   'dbo.Fact_GL_Transactions' TableName,
						   *
					FROM dbo.Fact_GL_Transactions
					ORDER BY 2 DESC;
	
	END	TRY
	
	BEGIN CATCH
		
				DECLARE @Error_Message VARCHAR(MAX) = ERROR_MESSAGE();
				EXEC    Utility.ToLog @Log_Source, @Log_Start_Date, @Error_Message, 'E', NULL, NULL;
				EXEC	Utility.FromLog @Log_Source, @Log_Start_Date;
				THROW;  -- Rethrow the error!
	
	END CATCH;

END

/*
--===============================================================================================================
-- !!! DEVELOPER TESTING ZONE to thoroughly test the code for various scenarios !!!
--===============================================================================================================
EXEC dbo.Fact_GL_Transactions_Full_Load

EXEC Utility.FromLog 'dbo.Fact_GL_Transactions', 1
SELECT TOP 100 'dbo.Fact_GL_Transactions' Table_Name, * FROM dbo.Fact_GL_Transactions ORDER BY 2

--===============================================================================================================
-- !!! USEFUL DATA VALIDATION SCRIPTS for post prod move monitoring or for others to not reinvent the wheel !!! 
--===============================================================================================================


*/


