CREATE PROC [Utility].[LongPrint] @sql [VARCHAR](MAX) AS
/*
IF OBJECT_ID ('Utility.LongPrint', 'P') IS NOT NULL DROP PROCEDURE Utility.LongPrint
GO

###################################################################################################################
Example:
-------------------------------------------------------------------------------------------------------------------
DECLARE @sql VARCHAR(MAX)
SELECT TOP 1 @sql = MODU.DEFINITION 
FROM SYS.PROCEDURES AS PR
JOIN sys.schemas s ON PR.[schema_id] = s.[schema_id] AND s.name = 'Utility'
JOIN SYS.SQL_MODULES AS MODU ON PR.OBJECT_ID = MODU.OBJECT_ID
WHERE PR.NAME = 'LongPrint'

EXEC Utility.LongPrint @sql 
===================================================================================================================
Proc Description: 
-------------------------------------------------------------------------------------------------------------------
This proc allow to print out on the screen the value of the variable even if it longer than 8000 characters (regular PRINT can print only first 8000)

@sql - Value to Print. May have any lenght
===================================================================================================================
Change Log:
-------------------------------------------------------------------------------------------------------------------
CHG0037837 Andy	01/10/2020	New!
###################################################################################################################
*/

BEGIN
	DECLARE @ST_R INT = 0
	DECLARE @CUT_LEN INT = 8000
	DECLARE @CUT_R INT = @CUT_LEN
	DECLARE @SQL_PART VARCHAR(8000)
	DECLARE @LONG INT = LEN(@sql)
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
END
