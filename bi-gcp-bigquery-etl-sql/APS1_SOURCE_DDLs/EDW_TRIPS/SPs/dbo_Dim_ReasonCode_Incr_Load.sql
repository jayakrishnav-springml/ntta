CREATE PROC [dbo].[Dim_ReasonCode_Incr_Load] AS

/*
IF OBJECT_ID ('dbo.Dim_ReasonCode_Incr_Load', 'P') IS NOT NULL DROP PROCEDURE dbo.Dim_ReasonCode_Incr_Load
GO
###################################################################################################################
Example:
-------------------------------------------------------------------------------------------------------------------
EXEC dbo.Dim_ReasonCode_Incr_Load 1

SELECT * FROM Utility.ProcessLog WHERE LogSource LIKE '%Dim_ReasonCode%' ORDER BY 1 DESC 
SELECT * FROM dbo.Dim_ReasonCode ORDER BY 2 
===================================================================================================================
Proc Description: 
-------------------------------------------------------------------------------------------------------------------
Load dbo.Dim_ReasonCode table. 
===================================================================================================================
Change Log:
-------------------------------------------------------------------------------------------------------------------
CHG0038319 	Andy		2021-03-08	New!
CHG0040134	Shankar		2021-12-15	Misc. Optimization.
CHG0041377	Shankar		2022-08-22	This proc should not run in full load mode after initial load to avoid SK values
									changing from one load to another, which causes data problems in fact tables.
									Renamed the proc to dbo.Dim_ReasonCode_Incr_Load and now it does only incr load.
###################################################################################################################
*/
BEGIN


	DECLARE @TableName VARCHAR(100) = 'dbo.Dim_ReasonCode', @StageTableName VARCHAR(100) = 'dbo.Dim_ReasonCode_NEW' 
	DECLARE @Log_Source VARCHAR(100) = 'dbo.Dim_ReasonCode_Incr_Load', @Log_Start_Date DATETIME2 (3) = SYSDATETIME(), @MAX_ID INT = 0
	DECLARE @Log_Message VARCHAR(1000), @Row_Count BIGINT, @Trace_Flag BIT = 0 -- Testing
	DECLARE @Last_Updated_Date DATETIME2(3), @sql VARCHAR(MAX)

/*
	--===========================================================================================================================================================================
	--:: DANGER! RISK OF DUMMY PRIMARY KEY VALUES CHANGING ON NEXT FULL LOAD! NEVER ENTERTAIN FULL LOAD OF DIM TABLES WHERE PRIMARY KEY VALUE DOES "NOT" COME FROM SOURCE SYSTEM.
	--===========================================================================================================================================================================
	IF @IsFullLoad = 1
	BEGIN

		SET @Log_Message = 'Started Full load'
		IF @Trace_Flag = 1 PRINT @Log_Message
		EXEC Utility.ToLog @Log_Source, @Log_Start_Date, @Log_Message, 'I', NULL, NULL

		IF OBJECT_ID('dbo.Dim_ReasonCode_NEW','U') IS NOT NULL			DROP TABLE dbo.Dim_ReasonCode_NEW;
		CREATE TABLE dbo.Dim_ReasonCode_NEW WITH (CLUSTERED INDEX(ReasonCodeID), DISTRIBUTION = REPLICATE) AS
		SELECT ROW_NUMBER() OVER (ORDER BY ReasonCode) AS ReasonCodeID, ReasonCode, @Log_Start_Date AS EDW_UpdateDate
		FROM (
					SELECT
						RTRIM(LTRIM(ReasonCode)) AS ReasonCode 
					FROM LND_TBOS.TOLLPLUS.TP_TRIPS
					WHERE ReasonCode IS NOT NULL
					GROUP BY RTRIM(LTRIM(ReasonCode))
				) A
		UNION ALL
		SELECT -1 AS ReasonCodeID, 'Unknown' AS ReasonCode, @Log_Start_Date AS EDW_UpdateDate
		OPTION (LABEL = 'dbo.Dim_ReasonCode_NEW');

		SET  @Log_Message = 'Loaded ' + @StageTableName
		EXEC Utility.FastLog @Log_Source, @Log_Message, -1

		CREATE STATISTICS STAT_dbo_Dim_ReasonCode_001 ON dbo.Dim_ReasonCode_NEW (ReasonCode);

		-- Table swap!
		EXEC Utility.TableSwap @StageTableName, @TableName

		SET @Log_Message = 'Completed full load'

	END

*/
	SELECT @MAX_ID = MAX(ReasonCodeID) FROM dbo.Dim_ReasonCode
	EXEC Utility.Get_UpdatedDate 'Dim_ReasonCode/TOLLPLUS.TP_TRIPS', @Last_Updated_Date OUTPUT 
	SET @Log_Message = 'Started Incremental load from: ' + CONVERT(VARCHAR(25),@Last_Updated_Date,121)
	IF @Trace_Flag = 1 PRINT @Log_Message
	EXEC Utility.ToLog @Log_Source, @Log_Start_Date, @Log_Message, 'I', NULL, NULL

	IF OBJECT_ID('stage.Dim_ReasonCode','U') IS NOT NULL	DROP TABLE stage.Dim_ReasonCode
	CREATE TABLE stage.Dim_ReasonCode WITH (HEAP, DISTRIBUTION = HASH(ReasonCodeID)) AS
	SELECT ISNULL(@MAX_ID,0) + ROW_NUMBER() OVER (ORDER BY ReasonCode) AS ReasonCodeID, ReasonCode, @Log_Start_Date AS EDW_UpdateDate
	FROM (
				SELECT	 DISTINCT RTRIM(LTRIM(ReasonCode)) AS ReasonCode 
				FROM	LND_TBOS.TOLLPLUS.TP_TRIPS TT
				WHERE	ReasonCode IS NOT NULL 
						AND LND_UpdateDate > @Last_Updated_Date
						AND NOT EXISTS (SELECT 1 FROM dbo.Dim_ReasonCode RC WHERE RC.ReasonCode = TT.ReasonCode)
			) A
	
	OPTION (LABEL = 'stage.Dim_ReasonCode')

	SELECT @Row_Count = COUNT(1) FROM stage.Dim_ReasonCode

	IF @Row_Count > 0
	BEGIN
		INSERT INTO dbo.Dim_ReasonCode SELECT * FROM stage.Dim_ReasonCode

		SET  @Log_Message = 'Inserted ' + CONVERT(VARCHAR,@Row_Count) + ' rows into dbo.Dim_ReasonCode'
		EXEC Utility.FastLog @Log_Source, @Log_Message, -1

		UPDATE STATISTICS dbo.Dim_ReasonCode
	END 

	EXEC Utility.Set_UpdatedDate 'Dim_ReasonCode/TOLLPLUS.TP_TRIPS', 'LND_TBOS.TOLLPLUS.TP_TRIPS', NULL 

	SET @Log_Message = 'Completed Incremental load from: ' + CONVERT(VARCHAR(25),@Last_Updated_Date,121)
	EXEC Utility.FastLog @Log_Source, @Log_Message, -1

	IF @Trace_Flag = 1 
	BEGIN
			SELECT TOP 5 * FROM Utility.ProcessLog WHERE LogSource LIKE '%Dim_ReasonCode%' ORDER BY 1 DESC
            SELECT * FROM Utility.LoadProcessControl WHERE TableName = 'Dim_ReasonCode/TOLLPLUS.TP_TRIPS'
			SELECT * FROM dbo.Dim_ReasonCode ORDER BY 1 DESC
 			SELECT	 DISTINCT RTRIM(LTRIM(ReasonCode)) AS ReasonCode 
			FROM	LND_TBOS.TOLLPLUS.TP_TRIPS TT
			WHERE	ReasonCode IS NOT NULL 
					AND LND_UpdateDate > @Last_Updated_Date
	END
END

 
/*
--===============================================================================================================
-- !!! DEVELOPER TESTING ZONE to thoroughly test the code for various scenarios !!!
--===============================================================================================================
SELECT * FROM Utility.LoadProcessControl WHERE TableName = 'Dim_ReasonCode/TOLLPLUS.TP_TRIPS'
EXEC dbo.Dim_ReasonCode_Incr_Load 
SELECT * FROM Utility.ProcessLog WHERE LogSource LIKE '%Dim_ReasonCode%' ORDER BY 1 desc
 
--:: Testing

DECLARE @Last_Updated_Date DATETIME2(3)
EXEC Utility.Get_UpdatedDate 'Dim_ReasonCode/TOLLPLUS.TP_TRIPS', @Last_Updated_Date OUTPUT
PRINT @Last_Updated_Date  

EXEC Utility.Set_UpdatedDate 'Dim_ReasonCode/TOLLPLUS.TP_TRIPS', NULL, '2022-08-01'

EXEC dbo.Dim_ReasonCode_Incr_Load 

DECLARE @Last_Updated_Date DATETIME2(3)
EXEC Utility.Get_UpdatedDate 'Dim_ReasonCode/TOLLPLUS.TP_TRIPS', @Last_Updated_Date OUTPUT
PRINT @Last_Updated_Date  

SELECT TOP 10 * FROM Utility.ProcessLog WHERE LogSource LIKE '%Dim_ReasonCode%' ORDER BY 1 desc
SELECT * FROM dbo.Dim_ReasonCode ORDER BY 1 DESC
SELECT * FROM Utility.LoadProcessControl WHERE TableName = 'Dim_ReasonCode/TOLLPLUS.TP_TRIPS'

*/

