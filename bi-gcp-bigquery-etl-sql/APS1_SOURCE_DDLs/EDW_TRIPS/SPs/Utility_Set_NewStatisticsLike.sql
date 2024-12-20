CREATE PROC [Utility].[Set_NewStatisticsLike] @Main_Table [VARCHAR](130),@Example_Table [VARCHAR](130) AS

/*
USE EDW_TRIPS
GO
IF OBJECT_ID ('Utility.Set_NewStatisticsLike', 'P') IS NOT NULL DROP PROCEDURE Utility.Set_NewStatisticsLike
GO

###################################################################################################################
Example:
-------------------------------------------------------------------------------------------------------------------
DECLARE @Main_Table VARCHAR(130) = 'Stage.Courts', @Example_Table VARCHAR(130) = 'court.Courts'
EXEC Utility.Set_NewStatisticsLike @Main_Table, @Example_Table 

===================================================================================================================
Proc Description: 
-------------------------------------------------------------------------------------------------------------------
This proc is creating statistics on the table exactly the same as existing statistics on the exapmle table.

@Main_Table - table name for wich statistics should be created (stage or switch table assumed)
@Example_Table - Table from where should statistics be taken. Does not checking for fields existing! It's assumed to be the equal table.

===================================================================================================================
Change Log:
-------------------------------------------------------------------------------------------------------------------
CHG0037837 Andy	01/10/2020	New!
###################################################################################################################
*/

BEGIN
	/*====================================== TESTING =======================================================================*/
	--DECLARE @Main_Table VARCHAR(130) = 'Stage.Courts', @Example_Table VARCHAR(130) = 'court.Courts'
	/*====================================== TESTING =======================================================================*/

	DECLARE @DROP_STATISTICS_SQL_String VARCHAR(MAX) = '', @CREATE_STATISTICS_SQL_String VARCHAR(MAX) = '', @Log_Message VARCHAR(1000)

	EXEC Utility.Get_DropStatistics_SQL @Main_Table, @DROP_STATISTICS_SQL_String  
	EXEC Utility.Get_CreateStatistics_SQL @Example_Table, @Main_Table, @CREATE_STATISTICS_SQL_String  

	BEGIN TRY
		EXECUTE (@DROP_STATISTICS_SQL_String)
		EXECUTE (@CREATE_STATISTICS_SQL_String)

		SET @Log_Message = 'Utility.Set_NewStatisticsLike: new statistics biult on ' + REPLACE(REPLACE(@Main_Table,'[',''),']','') + ' from ' + REPLACE(REPLACE(@Example_Table,'[',''),']','');
		EXEC Utility.FastLog @Main_Table, @Log_Message, NULL
	END	TRY
	BEGIN CATCH
		
		SET @Log_Message = 'Utility.Set_NewStatisticsLike Error: ' + ERROR_MESSAGE();
		EXEC    Utility.FastLog @Main_Table, @Log_Message, -3;
		THROW;  -- Rethrow the error!
	
	END CATCH

END




