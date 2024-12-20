CREATE PROC [DBO].[PRINT_LONG_VARIABLE_VALUE] @sql [VARCHAR](MAX) AS
/*

USE EDW_RITE
GO

IF EXISTS (SELECT * 
            FROM   sysobjects 
            WHERE  id = object_id('DBO.PRINT_LONG_VARIABLE_VALUE') 
                   and OBJECTPROPERTY(id, 'IsProcedure') = 1 )
DROP PROCEDURE DBO.PRINT_LONG_VARIABLE_VALUE
GO

-- !!!! EXAMPLE !!!! --

DECLARE @sql [VARCHAR](MAX)
SELECT @sql = MODU.DEFINITION 
FROM SYS.PROCEDURES AS PR
JOIN SYS.SQL_MODULES AS MODU ON PR.OBJECT_ID = MODU.OBJECT_ID
WHERE PR.NAME = 'FACT_UNIFIED_VIOLATION_LOAD'

EXEC EDW_RITE.DBO.PRINT_LONG_VARIABLE_VALUE @sql 

-- !!!! EXAMPLE !!!! --

*/

	DECLARE @ST_R INT = 1
	DECLARE @CUT_LEN INT = 8000
	DECLARE @CUT_R INT = @CUT_LEN
	DECLARE @SQL_PART VARCHAR(8000)
	DECLARE @LONG INT = LEN(@sql)
	DECLARE @SQL_PART_LONG INT
	DECLARE @SQL_PART_REV VARCHAR(MAX)
	DECLARE @LAST_ENTER_SYMBOL_NBR INT

	WHILE (@ST_R <= @LONG)
	BEGIN
		SET @SQL_PART = SUBSTRING(@sql, @ST_R, @CUT_LEN)
		SET @CUT_R = LEN(@SQL_PART) 
		-- Every time we print something - it prints on the next row
		-- it means, if we stopped in the middle of the row the next part of this row will be on the next row - we don't want this

		IF @ST_R + @CUT_LEN < @LONG -- it does not metter if this is the last part
		BEGIN
			SET @SQL_PART_REV = REVERSE(@SQL_PART)

			-- We are looking for the last "ENTER" symbol in our string part and cutting out everything after this - it will go to the next part
			-- To find it better to reverse the string
			SET @LAST_ENTER_SYMBOL_NBR = CHARINDEX(CHAR(13),@SQL_PART_REV)

			IF @LAST_ENTER_SYMBOL_NBR > 0
			BEGIN
				SET @SQL_PART = LEFT(@SQL_PART, @CUT_R - @LAST_ENTER_SYMBOL_NBR)
				-- Now should set a new length of the string part plus Enter symbol we don't want to have again
				SET @CUT_R = @CUT_R - @LAST_ENTER_SYMBOL_NBR + 1
			END
		END

		PRINT @SQL_PART
		-- Set beginning of the next part as the last part beginning + length of string part + next sybmol (+1) 
		SET @ST_R = @ST_R + @CUT_R + 1
	END


