CREATE PROC [dbo].[Fact_GL_Txn_LineItems_Full_Load] AS
/*
###################################################################################################################
Proc Description: 
-------------------------------------------------------------------------------------------------------------------
Load dbo.Fact_GL_Txn_LineItems table. 
===================================================================================================================
Change Log:
-------------------------------------------------------------------------------------------------------------------
CHG0037838 	Arun		2020-11-01	New!
CHG0038040  Arun Krishna 2021-01-27 -- Added Delete Flag 


===================================================================================================================
Example:
--------------------------------------------------------------------------------------------------------------
EXEC dbo.Fact_GL_Txn_LineItems_Full_Load
EXEC Utility.FromLog 'dbo.Fact_GL_Txn_LineItems', 1
SELECT TOP 100 'dbo.Fact_GL_Txn_LineItems' Table_Name, * FROM dbo.Fact_GL_Txn_LineItems ORDER BY 2
###################################################################################################################
*/
BEGIN
	BEGIN TRY

				DECLARE @Log_Source VARCHAR(100) = 'dbo.Fact_GL_Txn_LineItems_Full_Load',@Log_Start_Date DATETIME2(3) = SYSDATETIME();
				DECLARE @Log_Message VARCHAR(1000),@Row_Count BIGINT,@Trace_Flag BIT = 0; -- Testing
				EXEC    Utility.ToLog @Log_Source, @Log_Start_Date, 'Started full load', 'I', NULL, NULL;

				--=============================================================================================================
				-- Load dbo.Fact_GL_Txn_LineItems
				--=============================================================================================================
				IF OBJECT_ID('dbo.Fact_GL_Txn_LineItems_NEW') IS NOT NULL DROP TABLE dbo.Fact_GL_Txn_LineItems_NEW;
				CREATE TABLE dbo.Fact_GL_Txn_LineItems_NEW  WITH (CLUSTERED INDEX ( [PK_ID] DESC ), DISTRIBUTION = HASH([PK_ID])) 
				AS
				SELECT 
				 PK_ID
				,Gl_TxnID
				,[Description] AS Description
				,ChartOfAccountID
				,DebitAmount
				,CreditAmount
				,SpecialJournalID
				,Drcr_Flag
				,TxnType_Li_ID
				,TxnTypeID
				,CreatedDate
				,CreatedUser
				,UpdatedDate
				,UpdatedUser
				,CAST(CASE WHEN LND_UpdateType = 'D' THEN 1 ELSE 0 END AS BIT) DeleteFlag
				,LND_UpdateDate
				,CAST(SYSDATETIME() AS DATETIME2(3)) AS EDW_UpdateDate
				FROM LND_TBOS.Finance.GL_Txn_LineItems
				WHERE LND_UpdateType <> 'D'

				OPTION (LABEL = 'dbo.Fact_GL_Txn_LineItems_NEW Load');;;
		
				SET @Log_Message = 'Loaded dbo.Fact_GL_Txn_LineItems_NEW';
				EXEC Utility.ToLog @Log_Source,@Log_Start_Date,@Log_Message,'I',-1,NULL;

				-- Table swap!
				EXEC Utility.TableSwap 'dbo.Fact_GL_Txn_LineItems_NEW', 'dbo.Fact_GL_Txn_LineItems';

				EXEC Utility.ToLog @Log_Source,@Log_Start_Date,'Completed full load','I',NULL,NULL;

				-- Show results
				IF @Trace_Flag = 1
					EXEC Utility.FromLog @Log_Source, @Log_Start_Date;
				IF @Trace_Flag = 1
					SELECT TOP 1000
							'dbo.Fact_GL_Txn_LineItems' TableName,
							*
					FROM dbo.Fact_GL_Txn_LineItems
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
EXEC dbo.Fact_GL_Txn_LineItems_Full_Load

EXEC Utility.FromLog 'dbo.Fact_GL_Txn_LineItems', 1
SELECT TOP 100 'dbo.Fact_GL_Txn_LineItems' Table_Name, * FROM dbo.Fact_GL_Txn_LineItems ORDER BY 2

--===============================================================================================================
-- !!! USEFUL DATA VALIDATION SCRIPTS for post prod move monitoring or for others to not reinvent the wheel !!! 
--===============================================================================================================


*/


