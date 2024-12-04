CREATE OR REPLACE PROCEDURE `EDW_TRIPS_SUPPORT.Get_Where_String`(table_name STRING, identifyingcolumns STRING, OUT sql_string STRING)
BEGIN
/*
USE EDW_TRIPS 
GO
IF OBJECT_ID ('Utility.Get_Where_String', 'P') IS NOT NULL DROP PROCEDURE Utility.Get_Where_String
GO

###################################################################################################################
Example:
-------------------------------------------------------------------------------------------------------------------
DECLARE @SQL_String VARCHAR(4000)
EXEC Utility.Get_Where_String '[COURT].[Counties]','[CountyID]', @SQL_String OUTPUT 
EXEC Utility.LongPrint @SQL_String
===================================================================================================================
Proc Description: 
-------------------------------------------------------------------------------------------------------------------
This proc creating and returning part of SQL statement to use in Where statement in the special queries - uses only from PartitionSwitch procs.
Returning string like '[Table].[ColumnID] = [NSET].[ColumnID]'

@Table_Name - Table name (with Schema) is example for copy
@IdentifyingColumns - List of the columns to uniqually identify rows in both tables.  Needed - can't be empty or Null. 
@SQL_String - Param to return SQL statement. 
===================================================================================================================
Change Log:
-------------------------------------------------------------------------------------------------------------------
CHG0037837 Andy	01/10/2020	New!
###################################################################################################################
*/

    /*====================================== TESTING =======================================================================*/
	##DECLARE @SQL_String VARCHAR(4000), @Table_Name VARCHAR(200) = '[COURT].[Counties]', @IdentifyingColumns VARCHAR(100) = '[CountyID]'
	/*====================================== TESTING =======================================================================*/
    DECLARE error STRING DEFAULT '';
    DECLARE table STRING;
    DECLARE schema STRING;
    DECLARE indicat INT64 DEFAULT 1;
    DECLARE num_of_columns INT64;
    DECLARE delimiter_and STRING DEFAULT '';
    DECLARE columnname STRING;
    IF table_name IS NULL THEN
      SET error = concat(error, 'Table name cannot be NULL');
    END IF;
    SET sql_string = '';
    IF length(rtrim(error)) > 0 THEN
      ## BigQuery does not support any equivalent for PRINT or LOG.
	  SELECT error;
    ELSE
      BEGIN
        DECLARE dot INT64;
        SET dot = strpos(table_name, '.');
       SET (schema,table)= (SELECT
           ( CASE
              WHEN dot = 0 THEN 'EDW_TRIPS'
              ELSE replace(replace(replace(left(table_name, dot), '[', ''), ']', ''), '.', '')
            END,
            CASE
              WHEN dot = 0 THEN replace(replace(table_name, '[', ''), ']', '')
              ELSE replace(replace(substr(table_name, greatest(dot + 1, 0), CASE
                WHEN dot + 1 < 1 THEN greatest(dot + 1 + (200 - 1), 0)
                ELSE 200
              END), '[', ''), ']', '')
            END))
        ;
        DROP TABLE IF EXISTS _SESSION.table_columns;
        CREATE TEMPORARY TABLE _SESSION.table_columns
          AS
           SELECT
                 c.column_name  AS columnname,
                row_number() OVER (ORDER BY c.ordinal_position) AS rn
              FROM
                    region-us-south1.INFORMATION_SCHEMA.COLUMNS AS c              
              WHERE
                    table_schema=schema
                AND table_name  =table AND 
               CASE
                WHEN  c.column_name = '' THEN 0
                ELSE strpos(identifyingcolumns, c.column_name)
              END > 0
        ;
        SET num_of_columns = (SELECT
            max(`#table_columns`.rn)
          FROM
            _SESSION.table_columns AS `#table_columns`)
        ;
        WHILE indicat <= num_of_columns DO
          SET columnname = (SELECT
              m.columnname 
            FROM
              _SESSION.table_columns AS m
            WHERE m.rn = indicat)
          ;
          SET sql_string = concat(sql_string, delimiter_and,table, '.', columnname,' = [NSET].', columnname);
          SET delimiter_and = ' AND ';
          ##No target-dialect support for source-dialect-specific SET
		  SET INDICAT = INDICAT+1;
        END WHILE;
      END;
    END IF;
  END;