CREATE PROC [dbo].[PROCEDURES_GET_NO_COMMENTS_DEFINITION] @PROC_DEFENITION [VARCHAR](200),@PROC_TEXT_NEW [VARCHAR](MAX) OUT AS

/*
USE EDW_RITE
GO
USE SANDBOX

IF EXISTS (SELECT * 
            FROM   sysobjects 
            WHERE  id = object_id('DBO.PROCEDURES_GET_NO_COMMENTS_DEFINITION') 
                   and OBJECTPROPERTY(id, 'IsProcedure') = 1 )
DROP PROCEDURE DBO.PROCEDURES_GET_NO_COMMENTS_DEFINITION
GO


DECLARE DECLARE @PROC_TEXT_NEW VARCHAR(MAX)
EXEC DBO.PROCEDURES_GET_NO_COMMENTS_DEFINITION 'FACT_NET_REV_TFC_EVTS_INCR_LOAD', @PROC_TEXT_NEW


*/

--DECLARE @PROC_NAME VARCHAR(200) = 'FACT_NET_REV_TFC_EVTS_LOAD'

IF @PROC_DEFENITION IS NOT NULL
BEGIN

	--DECLARE @PROC_TEXT_NEW VARCHAR(MAX)
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

	--SELECT 
	--	@PROC_TEXT = CAST(MODU.DEFINITION AS VARCHAR(MAX))
	--FROM SYS.PROCEDURES AS PR 
	--JOIN SYS.schemas S ON S.schema_id = PR.schema_id AND S.name = 'DBO'
	--LEFT JOIN SYS.SQL_MODULES AS MODU ON PR.OBJECT_ID = MODU.OBJECT_ID
	--WHERE PR.Name = @PROC_NAME

	--EXEC dbo.PRINT_LONG_VARIABLE_VALUE @PROC_TEXT
	--SET @PROC_TEXT_NEW = @PROC_TEXT

	SET @ISCOM = 1

	SET @PROC_TEXT = REPLACE(@PROC_TEXT,'[','')
	SET @PROC_TEXT = REPLACE(@PROC_TEXT,']','')

	WHILE @ISCOM = 1
	BEGIN
		
		SELECT @POS_SB = CHARINDEX('/*',@PROC_TEXT)
		SELECT @POS_CB = CHARINDEX('--',@PROC_TEXT)

		IF @POS_SB > 0 AND (@POS_SB < @POS_CB OR @POS_CB = 0) -- '/*'
		BEGIN
			SELECT @POS_SE = ISNULL(NULLIF(CHARINDEX('*/',@PROC_TEXT, @POS_SB),0) + 2, LEN(@PROC_TEXT))
			SELECT @POS_SB1 = ISNULL(NULLIF(CHARINDEX('/*',@PROC_TEXT, @POS_SB + 2),0), LEN(@PROC_TEXT))
			PRINT '@POS_SB (/*)= ' + CAST(@POS_SB AS VARCHAR(10))
			PRINT '@POS_SE (*/)= ' + CAST(@POS_SE AS VARCHAR(10))
			PRINT '@POS_SB1 (/*)= ' + CAST(@POS_SB1 AS VARCHAR(10))

			WHILE @POS_SB1 < @POS_SE
			BEGIN
				SET @POS_SE1 = @POS_SE
				SELECT @POS_SE = ISNULL(NULLIF(CHARINDEX('*/',@PROC_TEXT, @POS_SE1),0) + 2, LEN(@PROC_TEXT))
				SET @POS_SB2 = @POS_SB1
				SELECT @POS_SB1 = ISNULL(NULLIF(CHARINDEX('/*',@PROC_TEXT, @POS_SB2 + 2),0), LEN(@PROC_TEXT))

				PRINT '@POS_SE (*/)= ' + CAST(@POS_SE AS VARCHAR(10))
				PRINT '@POS_SB1 (/*)= ' + CAST(@POS_SB1 AS VARCHAR(10))
			END
			IF @POS_SE - @POS_SB < 8000
			BEGIN
				SET @SUBSTRING = SUBSTRING(@PROC_TEXT,@POS_SB,@POS_SE - @POS_SB)
				EXEC dbo.PRINT_LONG_VARIABLE_VALUE @SUBSTRING
			END
			SET @PROC_TEXT = LEFT(@PROC_TEXT,@POS_SB - 1) + RIGHT(@PROC_TEXT,LEN(@PROC_TEXT) - @POS_SE)

		END
		ELSE  -- '--'
		BEGIN
			IF @POS_CB > 0
			BEGIN
				SELECT @POS_CE = ISNULL(NULLIF(CHARINDEX(CHAR(13)+char(10),@PROC_TEXT, @POS_CB),0) + 1, LEN(@PROC_TEXT))
				PRINT '@POS_CB (--)= ' + CAST(@POS_CB AS VARCHAR(10))
				PRINT '@POS_CE (VK)= ' + CAST(@POS_CE AS VARCHAR(10))

				IF @POS_CE - @POS_CB < 8000
				BEGIN
					SET @SUBSTRING = SUBSTRING(@PROC_TEXT,@POS_CB,@POS_CE - @POS_CB)
					EXEC dbo.PRINT_LONG_VARIABLE_VALUE @SUBSTRING
				END

				SET @PROC_TEXT = LEFT(@PROC_TEXT,@POS_CB - 1) + RIGHT(@PROC_TEXT,LEN(@PROC_TEXT) - @POS_CE)

			END
			ELSE SET @ISCOM = 0
			
		END

		SET @FORCESTOP += 1
		IF (@FORCESTOP >= 9000) SET @ISCOM = 0

	END

	SET @PROC_TEXT_NEW = @PROC_TEXT

	EXEC dbo.PRINT_LONG_VARIABLE_VALUE @PROC_TEXT_NEW

	--IF (SELECT 1 FROM dbo.PROCEDURES_WITH_DEFINITIONS WHERE PROC_NAME = @PROC_NAME) IS NULL
	--BEGIN
	--	INSERT INTO dbo.PROCEDURES_WITH_DEFINITIONS (DB, PROC_NAME,PROC_DEFINITION,NO_COMMENTS_DEFINITION)
	--	VALUES ('EDW_RITE',@PROC_NAME,@PROC_TEXT_NEW,@PROC_TEXT)
	--END
	--ELSE
	--BEGIN
	--	UPDATE dbo.PROCEDURES_WITH_DEFINITIONS
	--	SET NO_COMMENTS_DEFINITION = @PROC_TEXT, PROC_DEFINITION = @PROC_TEXT_NEW
	--	WHERE PROC_NAME = @PROC_NAME AND DB = 'EDW_RITE'
	--END

END
