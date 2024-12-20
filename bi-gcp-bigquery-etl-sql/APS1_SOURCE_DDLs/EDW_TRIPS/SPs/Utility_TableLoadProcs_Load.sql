CREATE PROC [Utility].[TableLoadProcs_Load] AS
/*
USE EDW_TRIPS 
GO
IF OBJECT_ID ('Utility.TableLoadProcs_Load', 'P') IS NOT NULL DROP PROCEDURE Utility.TableLoadProcs_Load
GO
###################################################################################################################
Example:
-------------------------------------------------------------------------------------------------------------------
EXEC Utility.TableLoadingParams_Load
SELECT 'Utility.TableLoadProcs' TableName, * FROM Utility.TableLoadProcs
SELECT 'Utility.TableDependencies' TableName, * FROM Utility.TableDependencies

===================================================================================================================
Proc Description: 
-------------------------------------------------------------------------------------------------------------------
This proc used for loading Utility tables TableLoadProcs and TableDependencies for every table in the system

After automate load it may need manual changes for several tables
===================================================================================================================
Change Log:
-------------------------------------------------------------------------------------------------------------------
CHG0037837	Andy	01/10/2020	New!
###################################################################################################################
*/

BEGIN

	IF OBJECT_ID('New.TableLoadProcs') IS NOT NULL DROP TABLE New.TableLoadProcs

	CREATE TABLE New.TableLoadProcs WITH (CLUSTERED INDEX (TableName), DISTRIBUTION = REPLICATE) AS
	WITH CTE_Tables AS
	(
		SELECT t.name AS TableName, S.name AS SchemaName, S.name + '.' + t.name AS Full_Name
		FROM SYS.tables T
		JOIN SYS.schemas S ON S.schema_id = T.schema_id AND S.name IN ('dbo','Stage')
		WHERE T.name NOT LIKE 'CTE_%' AND T.name NOT LIKE '%_OLD%' AND T.name NOT LIKE '%_STAGE%' AND T.name NOT LIKE '%_NEW%' AND T.name NOT LIKE '%_SWITCH%' AND T.name NOT LIKE '%_TRUNCATE%' AND T.name NOT LIKE '%_PART%' AND T.name NOT LIKE '%TEMP%' AND T.name NOT LIKE '%_PREV%' AND T.name NOT LIKE '%_FINAL%' AND T.name NOT LIKE '%TEST%'
			--AND S.name NOT IN('New','Old','Utility','Temp','Test','Dev','Ref') --AND S.name NOT LIKE 'NTTA\%'
	)
	, CTE_TABLE_StageLoad AS
	(
		SELECT T.SchemaName + '.' + T.TableName AS TableName, T.SchemaName + '.' + PR.name AS StageLoad
		FROM CTE_Tables AS T
		JOIN SYS.PROCEDURES AS PR ON PR.name IN (T.TableName + '_Stage_Load')
		JOIN SYS.schemas AS S ON S.schema_id = PR.schema_id AND S.name = T.SchemaName 
	)
	, CTE_TABLE_FullLoad AS
	(
		SELECT T.SchemaName + '.' + T.TableName AS TableName, T.SchemaName + '.' + PR.name AS FullLoad
		FROM CTE_Tables AS T
		JOIN SYS.PROCEDURES AS PR ON PR.name IN (T.TableName + '_Full_Load') 
		JOIN SYS.schemas AS S ON S.schema_id = PR.schema_id AND S.name = T.SchemaName 
	)
	, CTE_TABLE_IncrLoad AS
	(
		SELECT T.SchemaName + '.' + T.TableName AS TableName, T.SchemaName + '.' + PR.name AS IncrLoad
		FROM CTE_Tables AS T
		JOIN SYS.PROCEDURES AS PR ON PR.name IN (T.TableName + '_Incr_Load')
		JOIN SYS.schemas AS S ON S.schema_id = PR.schema_id AND S.name = T.SchemaName 
	)
	, CTE_TABLE_AllInOneLoad AS
	(
		SELECT T.SchemaName + '.' + T.TableName AS TableName, T.SchemaName + '.' + PR.name AS OneLoad
		FROM CTE_Tables AS T
		JOIN SYS.PROCEDURES AS PR ON PR.name IN (T.TableName + '_Load') 
		JOIN SYS.schemas AS S ON S.schema_id = PR.schema_id AND S.name = T.SchemaName 
	)
	SELECT T.Full_Name AS TableName, ISNULL(StageLoad,'') AS StageLoad, ISNULL(FullLoad,'') AS FullLoad, ISNULL(IncrLoad,'') AS IncrLoad, ISNULL(OneLoad,'') AS OneLoad, CAST(NULL AS INT) AS LoadLevel
	FROM CTE_Tables AS T
	LEFT JOIN CTE_TABLE_FullLoad F ON F.TableName = T.Full_Name 
	LEFT JOIN CTE_TABLE_IncrLoad I ON I.TableName = T.Full_Name 
	LEFT JOIN CTE_TABLE_StageLoad S ON S.TableName = T.Full_Name
	LEFT JOIN CTE_TABLE_AllInOneLoad R ON R.TableName = T.Full_Name

	IF OBJECT_ID('Old.TableLoadProcs') IS NOT NULL             DROP TABLE Old.TableLoadProcs;
	IF OBJECT_ID('Utility.TableLoadProcs') IS NOT NULL         ALTER SCHEMA Old TRANSFER OBJECT::Utility.TableLoadProcs; 
	IF OBJECT_ID('New.TableLoadProcs') IS NOT NULL             ALTER SCHEMA Utility TRANSFER OBJECT::New.TableLoadProcs;
	--IF OBJECT_ID('Old.TableLoadProcs') IS NOT NULL             DROP TABLE Old.TableLoadProcs;


	/*
	SELECT * 
	FROM Utility.TableLoadProcs
	*/

	IF OBJECT_ID('New.TableDependencies') IS NOT NULL DROP TABLE New.TableDependencies
	CREATE TABLE New.TableDependencies WITH (CLUSTERED INDEX (TableName), DISTRIBUTION = REPLICATE) AS
	WITH CTE_Tables AS
	(
		SELECT TableName, FullLoad, IncrLoad, OneLoad, StageLoad
		FROM Utility.TableLoadProcs
	)
	, CTE_DEPENDENCIES AS
	(
		SELECT T.TableName AS FOUND_TABLE, P.TableName AS USE_IN_TABLE
		FROM CTE_Tables AS T 
		LEFT JOIN (
					SELECT TableName,FullLoad AS ProcName FROM CTE_Tables 
					UNION ALL
					SELECT TableName,IncrLoad AS ProcName FROM CTE_Tables WHERE IncrLoad <> ''
					UNION ALL
					SELECT TableName,StageLoad AS ProcName FROM CTE_Tables WHERE StageLoad <> ''
					UNION ALL
					SELECT TableName,OneLoad AS ProcName FROM CTE_Tables WHERE OneLoad <> ''
					) P ON P.TableName <> T.TableName 
		LEFT JOIN Utility.ProcDefinitions AS PR ON PR.ProcName = P.ProcName 
			AND (
					PR.CLEAN_DEFINITION LIKE ('%' + T.TableName + ' %') 
					OR PR.CLEAN_DEFINITION LIKE ('%' + T.TableName + '	%') 
					OR PR.CLEAN_DEFINITION LIKE ('%' + T.TableName + CHAR(13) + '%') 
					OR PR.CLEAN_DEFINITION LIKE ('%' + T.TableName + ';%') 
					OR PR.CLEAN_DEFINITION LIKE ('%' + T.TableName + ')%') 
					OR PR.CLEAN_DEFINITION LIKE ('%' + T.TableName)
					)
		WHERE PR.ProcName IS NOT NULL
		GROUP BY T.TableName, P.TableName
	)
	SELECT C.USE_IN_TABLE AS TableToLoad, C.FOUND_TABLE AS DependsOnTable, CAST(ISNULL(D.ToControlLoad,0) AS SMALLINT) AS ToControlLoad
	FROM CTE_DEPENDENCIES C
	LEFT JOIN Utility.TableDependencies D ON D.TableName = C.USE_IN_TABLE AND D.DependsOnTable = C.FOUND_TABLE

	IF OBJECT_ID('Old.TableDependencies') IS NOT NULL             DROP TABLE Old.TableDependencies;
	IF OBJECT_ID('Utility.TableDependencies') IS NOT NULL         ALTER SCHEMA Old TRANSFER OBJECT::Utility.TableDependencies; 
	IF OBJECT_ID('New.TableDependencies') IS NOT NULL             ALTER SCHEMA Utility TRANSFER OBJECT::New.TableDependencies;

	UPDATE Utility.TableLoadProcs
	SET LoadLevel = NULL

	DECLARE @LoadLevel INT = 0
	DECLARE @STOP BIT = 0
	DECLARE @Row_Count BIGINT = 0

	WHILE @STOP = 0
	BEGIN

		IF OBJECT_ID('tempdb..#LoadLevel') IS NOT NULL DROP TABLE #LoadLevel

		SELECT 
			 P.TableName
		INTO #LoadLevel
		FROM Utility.TableLoadProcs P
		WHERE P.LoadLevel IS NULL
			AND NOT EXISTS (
							SELECT 1 
							FROM Utility.TableDependencies U 
							JOIN Utility.TableLoadProcs T 
								ON T.TableName = U.DependsOnTable 
								AND T.LoadLevel IS NULL 
							WHERE U.TableName = P.TableName
							) 

		EXEC	Utility.Row_Count @Row_Count OUTPUT

		IF @Row_Count > 0
		BEGIN
			PRINT @LoadLevel

			UPDATE Utility.TableLoadProcs
			SET LoadLevel = @LoadLevel
			FROM #LoadLevel P
			WHERE TableLoadProcs.TableName = P.TableName

			SET @LoadLevel += 1 
		END
		ELSE SET @STOP = 1

	END

END

/*
--===============================================================================================================
-- !!! DEVELOPER TESTING ZONE to thoroughly test the code for various scenarios !!!
--===============================================================================================================

	UPDATE Utility.TableLoadProcs
	SET FullLoad = ''
		,IncrLoad = ''
		,StageLoad = ''
	WHERE TableName = ''

	UPDATE Utility.TableDependencies
	SET ToControlLoad = 1
	WHERE DependsOnTable = 'dbo.DIM_CUSTOMER'

*/

