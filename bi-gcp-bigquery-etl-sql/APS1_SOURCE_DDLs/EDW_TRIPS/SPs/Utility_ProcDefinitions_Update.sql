CREATE PROC [Utility].[ProcDefinitions_Update] @Proc_Name [VARCHAR](200) AS

/*
USE EDW_TRIPS
GO
IF OBJECT_ID ('Utility.ProcDefinitions_Update', 'P') IS NOT NULL DROP PROCEDURE Utility.ProcDefinitions_Update
GO
###################################################################################################################
Example:
-------------------------------------------------------------------------------------------------------------------
EXEC Utility.ProcDefinitions_Update 'dbo.Dim_Customer_Load'

SELECT COUNT_BIG(1) FROM Utility.ProcDefinitions  

SELECT Table_Name,Proc_Name,Proc_Definition,Clean_Definition FROM Utility.ProcDefinitions WHERE Proc_Name = 'dbo.Dim_Customer_Load'
===================================================================================================================
Proc Description: 
-------------------------------------------------------------------------------------------------------------------
This proc updating a table Utility.ProcDefinitions that keeping definitions of procedures for table load with cleaned one
This may be used to find out all procs for table load and check which proc having the needed text

@Proc_Name - Name of the proc to Update info
===================================================================================================================
Change Log:
-------------------------------------------------------------------------------------------------------------------
CHG0037837		Andy	01/10/2020	New!
###################################################################################################################

*/

BEGIN

	/*====================================== TESTING =======================================================================*/
	--DECLARE @Proc_Name VARCHAR(200) = 'dbo.Dim_Customer_Full_Load' 
	/*====================================== TESTING =======================================================================*/

	DECLARE @ERROR VARCHAR(MAX) = ''

	IF @Proc_Name IS NULL SET @ERROR = @ERROR + 'Table name could not be NULL'

	IF LEN(@ERROR) > 0
	BEGIN
		PRINT @ERROR
	END
	ELSE
	BEGIN

		DECLARE @SCHEMA [VARCHAR](100)
		DECLARE @PROC [VARCHAR](200)

		DECLARE @DOT INT = CHARINDEX('.',@Proc_Name)

		IF @DOT = 0
		BEGIN
			SET @SCHEMA = 'dbo'
			SET @PROC = REPLACE(REPLACE(@Proc_Name,'[',''),']','')
		END
		ELSE
		BEGIN
			SET @SCHEMA = REPLACE(REPLACE(LEFT(@Proc_Name,@DOT - 1),'[',''),']','')
			SET @PROC = REPLACE(REPLACE(SUBSTRING(@Proc_Name,@DOT + 1,200),'[',''),']','')
		END

		DECLARE @PROC_TEXT_NEW VARCHAR(MAX)
		DECLARE @PROC_TEXT VARCHAR(MAX)
		DECLARE @Table_Name VARCHAR(200) = @SCHEMA + '.' + REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(@PROC,'_Load',''),'_Full',''),'_Incr',''),'_Stage',''),'_Run','')

		SELECT 
			@PROC_TEXT = CAST(MODU.DEFINITION AS VARCHAR(MAX))
		FROM SYS.PROCEDURES AS PR 
		JOIN SYS.schemas S ON S.schema_id = PR.schema_id AND S.name = @SCHEMA
		LEFT JOIN SYS.SQL_MODULES AS MODU ON PR.OBJECT_ID = MODU.OBJECT_ID
		WHERE PR.Name = @PROC

		EXEC Utility.Get_CleanProcDefInition @PROC_TEXT, @PROC_TEXT_NEW OUTPUT

		EXEC Utility.LongPrint @PROC_TEXT_NEW

		IF (SELECT 1 FROM Utility.ProcDefinitions WHERE Proc_Name = @Proc_Name) IS NULL
		BEGIN
			INSERT INTO Utility.ProcDefinitions (Table_Name,Proc_Name,Proc_Definition,Clean_Definition)
			VALUES (@Table_Name,@Proc_Name,@PROC_TEXT,@PROC_TEXT_NEW)
		END
		ELSE
		BEGIN
			UPDATE Utility.ProcDefinitions
			SET Proc_Definition = @PROC_TEXT, Clean_Definition = @PROC_TEXT_NEW
			WHERE Proc_Name = @Proc_Name --AND Table_Name = @Table_Name
		END

	END

END
