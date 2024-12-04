CREATE OR REPLACE PROCEDURE EDW_TRIPS_SUPPORT.LongPrint(sql STRING)
BEGIN
/*
USE EDW_TRIPS 
GO
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
    DECLARE st_r INT64 DEFAULT 0;
    DECLARE cut_len INT64 DEFAULT 8000;
    DECLARE cut_r INT64 DEFAULT cut_len;
    DECLARE sql_part STRING;
    DECLARE long INT64 DEFAULT length(rtrim(sql));
    DECLARE sql_part_rev STRING;
    DECLARE last_enter_symbol_nbr INT64;
    WHILE st_r <= long DO
      SET sql_part = substr(sql, greatest(st_r, 0), CASE
        WHEN st_r < 1 THEN greatest(st_r + (cut_len - 1), 0)
        ELSE cut_len
      END);
      SET cut_r = length(rtrim(sql_part));
      	## Every time we print something - it prints on the next row
		    ## it means, if we stopped in the middle of the row the next part of this row will be on the next row - we don't want this

	
      
      IF st_r + cut_len < long THEN
        SET sql_part_rev = reverse(sql_part);
        ## We are looking for the last "ENTER" symbol in our string part and cutting out everything after this - it will go to the next part
			  ## To find it better to reverse the string
		
        SET last_enter_symbol_nbr = CASE
          WHEN code_points_to_string(ARRAY[
            13
          ]) = '' THEN 0
          ELSE strpos(sql_part_rev, code_points_to_string(ARRAY[
            13
          ]))
        END;
        IF last_enter_symbol_nbr > 0 THEN
          SET sql_part = left(sql_part, cut_r - last_enter_symbol_nbr);
          ## Now should set a new length of the string part plus Enter symbol we don't want to have again
          SET cut_r = cut_r - last_enter_symbol_nbr + 1;
        END IF;
      END IF;
       SELECT sql_part;
        SET st_r = st_r + cut_r + 1;
       		## Set beginning of the next part as the last part beginning + length of string part + next sybmol (+1) 
 
    END WHILE;
  END;