CREATE PROC [Utility].[TableLoad_Run] @TableName [VARCHAR](200),@IsFullLoad [BIT] AS

/*

USE EDW_TRIPS 
GO
IF OBJECT_ID ('Utility.TableLoad_Run', 'P') IS NOT NULL DROP PROCEDURE Utility.TableLoad_Run
GO

###################################################################################################################
Example:
-------------------------------------------------------------------------------------------------------------------
EXEC Utility.TableLoad_Run 'dbo.Dim_Customer', 1
===================================================================================================================
Proc Description: 
-------------------------------------------------------------------------------------------------------------------
This proc used for atomated call of load proc. It can call and run Incr or full load. 
Also it controls do not load if it already loaded and do not load if the previous proc was not finished correctly.
Should be called from Data manager

@TableName - The name of the table to load. 
@IsFullLoad - flag to force use of the full load. It does not matters if there is only full load.
===================================================================================================================
Change Log:
-------------------------------------------------------------------------------------------------------------------
CHG0037837	Andy	01/10/2020	New!
###################################################################################################################
*/

BEGIN

	/*====================================== TESTING =======================================================================*/
	--DECLARE @TableName VARCHAR(200) = 'dbo.Dim_Customer',  @IsFullLoad BIT = 1
	/*====================================== TESTING =======================================================================*/

	DECLARE @Start_Date DATETIME2(3) = SYSDATETIME(), @ErrorMessage VARCHAR(4000), @InfoMessage VARCHAR(4000)
	DECLARE @SQL VARCHAR(MAX) = '', @Errors_CNT INT, @Load_CNT INT

	-- If it already was loaded - do not need to load again
	SELECT 
		@Load_CNT = COUNT(1)
	FROM Utility.TableLoadFacts C 
	WHERE ISNULL(C.Success,0) = 1 AND C.TableName = @TableName AND C.IsFullLoad = @IsFullLoad

	IF @Load_CNT = 0
	BEGIN

		IF @IsFullLoad IS NULL SET @IsFullLoad = 0

		-- If Table has proc which handles both Full Load and Incr Load, we should use it with parameter @IsFullLoad.
		SET @SQL = (SELECT	TOP 1 CASE WHEN OneLoad > '' THEN 'EXECUTE ' + OneLoad + ' ' + CAST(@IsFullLoad AS VARCHAR(1)) END
					FROM Utility.TableLoadProcs
					WHERE TableName = @TableName AND OneLoad <> '')


		-- SELECT @TableName  [@TableName ], @IsFullLoad [@IsFullLoad], @SQL [@SQL]
		-- Finding needed proc - Incr or Full load
		SELECT @SQL = 'EXECUTE ' + CASE 
										WHEN OneLoad <> '' THEN OneLoad + ' ' + CAST(@IsFullLoad AS VARCHAR(1))
										WHEN @IsFullLoad = 0 AND ISNULL(InrcLoad,'') <> '' THEN InrcLoad 
										ELSE FullLoad 
									END
		FROM Utility.TableLoadProcs
		WHERE TableName = @TableName

		IF OBJECT_ID('tempdb..#ANY_TABLE_Load_CHECK') IS NOT NULL DROP TABLE #ANY_TABLE_Load_CHECK

		--Checking if it has any source tables, that we need to control (Flag ToControlLoad = 1 in Utility.TableDependencies)
		-- that was not finished load Successfully - we put it to errors table
		CREATE TABLE #ANY_TABLE_Load_CHECK WITH (HEAP, DISTRIBUTION = REPLICATE) AS
		WITH CTE_DEP AS
		(
			SELECT DependsOnTable
			FROM Utility.TableDependencies
			WHERE TableName = @TableName AND ToControlLoad = 1
		)
		SELECT 
			ROW_NUMBER() OVER (ORDER BY TableName) AS RN,
			TableName, ISNULL(Success,0) AS Success, ISNULL(InfoMessage,'') InfoMessage
		FROM CTE_DEP D
		LEFT JOIN Utility.TableLoadFacts C ON C.TableName = D.DependsOnTable 
		WHERE ISNULL(Success,0) = 0

		-- Findind the count of missed source loads
		SELECT @Errors_CNT = COUNT(1) FROM #ANY_TABLE_Load_CHECK

		-- If no errors (all needed to control loads have Success = 1) - we can run this load.
		IF @Errors_CNT = 0
		BEGIN

			BEGIN TRY

				EXECUTE (@SQL) -- (it should be somthing like 'EXECUTE dbo.TableName_UncrLoad')
				-- No need to log from here - there are logs inside the load

				-- To Check if any table Depends on this table - we should insert result to Utility.TableLoadFacts
				INSERT INTO Utility.TableLoadFacts (TableName, InfoMessage, ActionDateTime, IsFullLoad, Success)
				VALUES (@TableName, @SQL, @Start_Date, @IsFullLoad, 1)

			END	TRY	
			BEGIN CATCH
			
				-- Have errors in a load - have to put it to the log
				SELECT @ErrorMessage = ERROR_MESSAGE();  
				SET @ErrorMessage = 'EXECUTE Load Failed: ' + @ErrorMessage
				EXEC Utility.FastLog @TableName, @ErrorMessage, -3;

				-- To Check if any table Depends on this table - we should insert result to Utility.TableLoadFacts
				INSERT INTO Utility.TableLoadFacts (TableName, InfoMessage, ActionDateTime, IsFullLoad, Success)
				VALUES (@TableName, @ErrorMessage, @Start_Date, @IsFullLoad, 0)
			END CATCH

		END
		ELSE
		BEGIN
		
			-- If there are some source tables not found in Success - we are not loading our table
			DECLARE @INDICAT SMALLINT = 1
			DECLARE @Delimiter VARCHAR(3) = ':'
			DECLARE @Message_String VARCHAR(MAX) = @SQL + ' was not kicked off in case of missed source tables loads'
			DECLARE @SELECT_String VARCHAR(MAX)

			-- Prepearing the message of the reason why we missed the load
			WHILE (@INDICAT <= @Errors_CNT)
			BEGIN
				SELECT @InfoMessage = TableName + ': ' + InfoMessage
				FROM #ANY_TABLE_Load_CHECK M
				WHERE M.RN = @INDICAT
		
				SET @Message_String = @Message_String + CHAR(13) + CHAR(10) + CHAR(9) + @Delimiter + @InfoMessage

				SET	@Delimiter = '; ' 
				SET @INDICAT += 1
			END
			-- and insert this massage to log
			EXEC Utility.FastLog @TableName, @Message_String, -3;

			-- and to Utility.TableLoadFacts if we have Dependent tables
			INSERT INTO Utility.TableLoadFacts (TableName, InfoMessage, Action_DateTime, IsFullLoad, Success)
			VALUES (@TableName, @Message_String, @Start_Date, @IsFullLoad, 0)

		END

	END
END
