CREATE PROC [Utility].[Get_CleanProcDefinition] @PROC_DEFENITION [VARCHAR](MAX),@PROC_TEXT_NEW [VARCHAR](MAX) OUT AS
/*
USE EDW_TRIPS
GO
IF OBJECT_ID ('Utility.Get_CleanProcDefinition', 'P') IS NOT NULL DROP PROCEDURE Utility.Get_CleanProcDefinition
GO

###################################################################################################################
Example:
-------------------------------------------------------------------------------------------------------------------
DECLARE @PROC_TEXT_NEW VARCHAR(MAX), @PROC_DEFENITION VARCHAR(MAX)
SELECT TOP 1 @PROC_DEFENITION = CAST(MODU.DEFINITION AS VARCHAR(MAX)) 
FROM SYS.PROCEDURES AS PR
JOIN sys.schemas s ON PR.[schema_id] = s.[schema_id] AND s.name = 'Utility'
JOIN SYS.SQL_MODULES AS MODU ON PR.OBJECT_ID = MODU.OBJECT_ID
WHERE PR.NAME = 'ToLog'

EXEC Utility.Get_CleanProcDefInition @PROC_DEFENITION, @PROC_TEXT_NEW

===================================================================================================================
Proc Description: 
-------------------------------------------------------------------------------------------------------------------
This proc creating and returning T-SQL text cleaned from any comments and [] brackets 
This may be useful if you are trying to find out is this proc text having some text that is not in comments (like table call or proc call)

@PROC_DEFENITION - Text of proc or Function you want to clean
@PROC_TEXT_NEW - Param to return cleaned SQL text
===================================================================================================================
Change Log:
-------------------------------------------------------------------------------------------------------------------
CHG0037837			Andy	01/10/2020	New!
###################################################################################################################

*/

BEGIN

	DECLARE @Trace_Flag BIT = 0
	
	/*====================================== TESTING =======================================================================*/
	--DECLARE @PROC_TEXT_NEW VARCHAR(MAX), @PROC_DEFENITION VARCHAR(MAX)
	--SELECT TOP 1 @PROC_DEFENITION = CAST(MODU.DEFINITION AS VARCHAR(MAX)) 
	--FROM SYS.PROCEDURES AS PR
	--JOIN sys.schemas s ON PR.[schema_id] = s.[schema_id] AND s.name = 'Utility'
	--JOIN SYS.SQL_MODULES AS MODU ON PR.OBJECT_ID = MODU.OBJECT_ID
	--WHERE PR.NAME = 'ToLog'
	/*====================================== TESTING =======================================================================*/

	IF @PROC_DEFENITION IS NOT NULL
	BEGIN

		DECLARE @PROC_TEXT VARCHAR(MAX) = @PROC_DEFENITION
		DECLARE @SUBSTRING VARCHAR(MAX)

		DECLARE @ISCOM BIT
		DECLARE @POS_SB BIGINT  -- STAR BEGIN position
		DECLARE @POS_SB1 BIGINT  -- STAR BEGIN position between star begin and star end (if it is)
		DECLARE @POS_SB2 BIGINT  -- STAR BEGIN roll position
		DECLARE @POS_SE BIGINT  -- STAR END position
		DECLARE @POS_SE1 BIGINT  -- STAR END roll position 
		DECLARE @POS_CB BIGINT	-- Comment begin position
		DECLARE @POS_CE	BIGINT  -- Comment end posotion (end of row)
		DECLARE @FORCESTOP INT = 0 -- Help to avoid infinite loop

		SET @ISCOM = 1

		SET @PROC_TEXT = REPLACE(REPLACE(@PROC_TEXT,'[',''),']','')

		WHILE @ISCOM = 1
		BEGIN
		
			SELECT @POS_SB = CHARINDEX('/*',@PROC_TEXT)
			SELECT @POS_CB = CHARINDEX('--',@PROC_TEXT)

			IF @POS_SB > 0 AND (@POS_SB < @POS_CB OR @POS_CB = 0) -- '/*'
			BEGIN
				SELECT @POS_SE = ISNULL(NULLIF(CHARINDEX('*/',@PROC_TEXT, @POS_SB),0) + 2, LEN(@PROC_TEXT))
				SELECT @POS_SB1 = ISNULL(NULLIF(CHARINDEX('/*',@PROC_TEXT, @POS_SB + 2),0), LEN(@PROC_TEXT))
				IF @Trace_Flag = 1
				BEGIN
					PRINT '@POS_SB (/*)= ' + CAST(@POS_SB AS VARCHAR(10))
					PRINT '@POS_SE (*/)= ' + CAST(@POS_SE AS VARCHAR(10))
					PRINT '@POS_SB1 (/*)= ' + CAST(@POS_SB1 AS VARCHAR(10))
				END
				WHILE @POS_SB1 < @POS_SE
				BEGIN
					SET @POS_SE1 = @POS_SE
					SELECT @POS_SE = ISNULL(NULLIF(CHARINDEX('*/',@PROC_TEXT, @POS_SE1),0) + 2, LEN(@PROC_TEXT))
					SET @POS_SB2 = @POS_SB1
					SELECT @POS_SB1 = ISNULL(NULLIF(CHARINDEX('/*',@PROC_TEXT, @POS_SB2 + 2),0), LEN(@PROC_TEXT))

					IF @Trace_Flag = 1
					BEGIN
						PRINT '@POS_SE (*/)= ' + CAST(@POS_SE AS VARCHAR(10))
						PRINT '@POS_SB1 (/*)= ' + CAST(@POS_SB1 AS VARCHAR(10))
					END
				END
				IF @POS_SE - @POS_SB < 8000 AND @Trace_Flag = 1
				BEGIN
					SET @SUBSTRING = SUBSTRING(@PROC_TEXT,@POS_SB,@POS_SE - @POS_SB)
					EXEC Utility.LongPrint @SUBSTRING
				END
				SET @PROC_TEXT = LEFT(@PROC_TEXT,@POS_SB - 1) + RIGHT(@PROC_TEXT,LEN(@PROC_TEXT) - @POS_SE)

			END
			ELSE  -- '--'
			BEGIN
				IF @POS_CB > 0
				BEGIN
					SELECT @POS_CE = ISNULL(NULLIF(CHARINDEX(CHAR(13)+CHAR(10),@PROC_TEXT, @POS_CB),0) + 1, LEN(@PROC_TEXT))
					IF @Trace_Flag = 1
					BEGIN
						PRINT '@POS_CB (--)= ' + CAST(@POS_CB AS VARCHAR(10))
						PRINT '@POS_CE (VK)= ' + CAST(@POS_CE AS VARCHAR(10))

						IF @POS_CE - @POS_CB < 8000
						BEGIN
							SET @SUBSTRING = SUBSTRING(@PROC_TEXT,@POS_CB,@POS_CE - @POS_CB)
							EXEC Utility.LongPrint @SUBSTRING
						END
					END

					SET @PROC_TEXT = LEFT(@PROC_TEXT,@POS_CB - 1) + CHAR(13)+CHAR(10) + RIGHT(@PROC_TEXT,LEN(@PROC_TEXT) - @POS_CE)

				END
				ELSE SET @ISCOM = 0
			
			END

			SET @FORCESTOP += 1
			IF (@FORCESTOP >= 9000) SET @ISCOM = 0

		END

		SET @PROC_TEXT_NEW = @PROC_TEXT

		EXEC Utility.LongPrint @PROC_TEXT_NEW

	END

END

/*

--:: Testing zone
SELECT * FROM Utility.ProcDefinitions


*/
