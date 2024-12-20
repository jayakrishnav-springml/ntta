CREATE PROC [Utility].[ProcDefinitions_Load] AS

/*
USE EDW_TRIPS
GO
IF OBJECT_ID ('Utility.ProcDefinitions_Load', 'P') IS NOT NULL DROP PROCEDURE Utility.ProcDefinitions_Load
GO
###################################################################################################################
Example:
-------------------------------------------------------------------------------------------------------------------
EXEC Utility.ProcDefinitions_Load

SELECT COUNT_BIG(1) FROM Utility.ProcDefinitions  

SELECT Table_Name,Proc_Name,Proc_Definition,Clean_Definition FROM Utility.ProcDefinitions

===================================================================================================================
Proc Description: 
-------------------------------------------------------------------------------------------------------------------
This proc creating and filling a table Utility.ProcDefinitions that keeping definitions of procedures for table load with cleaned one
This may be used to find out all procs for table load and check which proc having the needed text

===================================================================================================================
Change Log:
-------------------------------------------------------------------------------------------------------------------
CHG0037837			Andy	01/10/2020	New!
###################################################################################################################
*/

BEGIN
	
	DECLARE @Trace_Flag BIT = 0 -- Testing

	IF OBJECT_ID('Utility.ProcDefinitions') IS NULL
	BEGIN
		CREATE TABLE Utility.ProcDefinitions WITH (CLUSTERED INDEX (Proc_Name), DISTRIBUTION = REPLICATE) AS
		SELECT CAST('' AS VARCHAR(200)) AS Table_Name, CAST('' AS VARCHAR(200)) AS Proc_Name, CAST(''AS VARCHAR(MAX)) AS Proc_Definition, CAST('' AS VARCHAR(MAX)) AS Clean_Definition
	END

	IF OBJECT_ID('tempdb..#ProcDefinitions') IS NOT NULL DROP TABLE #ProcDefinitions

	CREATE TABLE #ProcDefinitions WITH (HEAP, DISTRIBUTION = REPLICATE) AS
	SELECT 
		ROW_NUMBER() OVER (ORDER BY PR.name) AS NN,
		CAST(S.name + '.' + REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(PR.name,'_Load',''),'_Full',''),'_Incr',''),'_Stage',''),'_Run','') AS VARCHAR(200)) AS Table_Name,
		CAST(S.name + '.' + PR.name AS VARCHAR(200)) AS Proc_Name, 
		CAST(MODU.DEFINITION AS VARCHAR(MAX)) AS Proc_Definition
	FROM SYS.PROCEDURES AS PR 
	JOIN SYS.schemas S ON S.schema_id = PR.schema_id  AND S.name IN ('dbo','Stage')
	LEFT JOIN SYS.SQL_MODULES AS MODU ON PR.OBJECT_ID = MODU.OBJECT_ID
	WHERE PR.Name NOT LIKE '%_OLD%' AND PR.Name NOT LIKE '%TEMP%' AND PR.Name NOT LIKE '%_PREV%' AND PR.Name NOT LIKE '%TEST%' AND PR.Name NOT LIKE '%_RUN%'
			--AND S.name IN ('dbo','Stage') -- For EDW_TBOS database need to uncomment this.
			
	DECLARE @MAX_NN INT = (SELECT MAX(NN) FROM #ProcDefinitions)
	DECLARE @TEC_NN INT = 1

	DECLARE @Table_Name VARCHAR(200)
	DECLARE @Proc_Name VARCHAR(200)
	DECLARE @Proc_Text VARCHAR(MAX) 
	DECLARE @Proc_Text_New VARCHAR(MAX) = ''

	IF @Trace_Flag = 1 SELECT * FROM #ProcDefinitions ORDER BY NN

	-- LOOP on Procs
	WHILE @TEC_NN <= @MAX_NN
	BEGIN

		SELECT @Table_Name = Table_Name, @Proc_Name = Proc_Name, @Proc_Text = Proc_Definition FROM #ProcDefinitions WHERE NN = @TEC_NN

		EXEC Utility.Get_CleanProcDefInition @Proc_Text, @Proc_Text_New OUTPUT

		IF (SELECT 1 FROM Utility.ProcDefinitions WHERE Proc_Name = @Proc_Name) IS NULL
		BEGIN
			INSERT INTO Utility.ProcDefinitions (Table_Name,Proc_Name,Proc_Definition,Clean_Definition)
			VALUES (@Table_Name,@Proc_Name,@Proc_Text,@Proc_Text_New)
		END
		ELSE
		BEGIN
			UPDATE Utility.ProcDefinitions
			SET Proc_Definition = @Proc_Text, Clean_Definition = @Proc_Text_New
			WHERE Proc_Name = @Proc_Name --AND Table_Name = @Table_Name
		END

		SET @TEC_NN += 1
	END
END	

/*

--:: Testing zone

DECLARE @Table_Name VARCHAR(200) = 'dbo.DIM_AGENCY', @Clean_Definition VARCHAR(MAX)
SELECT @Clean_Definition = PR.Clean_Definition FROM Utility.ProcDefinitions PR WHERE PR.Table_Name = 'dbo.DIM_CUSTOMER'
EXEC SRV.LongPrint @sql = @Clean_Definition 

SELECT * FROM Utility.ProcDefinitions PR
WHERE PR.CLEAN_DEFINITION LIKE ('%' + @Table_Name + ' %') 
					OR PR.CLEAN_DEFINITION LIKE ('%' + @Table_Name + '	%') 
					OR PR.CLEAN_DEFINITION LIKE ('%' + @Table_Name + CHAR(13) + '%') 
					OR PR.CLEAN_DEFINITION LIKE ('%' + @Table_Name + ';%') 
					OR PR.CLEAN_DEFINITION LIKE ('%' + @Table_Name + ')%') 
					OR PR.CLEAN_DEFINITION LIKE ('%' + @Table_Name)


*/
