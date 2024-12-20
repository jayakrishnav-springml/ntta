CREATE PROC [Utility].[ToSSIS] @LogSource [VARCHAR](100),@ProcStartDate [DATETIME2](3),@LogMessage [VARCHAR](4000),@LogType [VARCHAR](1),@Row_Count [BIGINT],@Step [VARCHAR](10) AS
/*
USE LND_TBOS
GO
IF OBJECT_ID ('Utility.ToSSIS', 'P') IS NOT NULL DROP PROCEDURE Utility.ToSSIS
GO
###################################################################################################################
Purpose: Log ETL process execution details in Utility.ProcessLog table. 
-------------------------------------------------------------------------------------------------------------------
Change Log:
-------------------------------------------------------------------------------------------------------------------
CHG0037837	Andy and Shankar		2020-08-20	New!
-------------------------------------------------------------------------------------------------------------------
Example:
-------------------------------------------------------------------------------------------------------------------
EXEC Utility.ToSSIS 'dbo.Dim_CollectionStatus', '2020-08-20 10:46:29.193', 'Started full load', 'I', NULL, 'Step:1'
SELECT TOP 100 * FROM Utility.ProcessLog ORDER BY 1 DESC
###################################################################################################################
*/

BEGIN
	DECLARE @LogDate DATETIME2(3) = SYSDATETIME()

	EXEC Utility.ToLog @LogSource, @ProcStartDate, @LogMessage, @LogType, @Row_Count, NULL

	INSERT INTO Utility.SSISLoadCheck
			(
				LoadDate, 
				LoadSource, 
				LoadStep,
				LoadInfo,
				Row_Count
			)
	VALUES  (
				@LogDate, 
				@LogSource, 
				@Step,
				@LogMessage,
				@Row_Count
			)

END



