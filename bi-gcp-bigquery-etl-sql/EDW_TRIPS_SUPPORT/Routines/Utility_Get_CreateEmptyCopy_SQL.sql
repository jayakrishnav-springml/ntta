-- Translation time: 2024-03-05T10:34:47.496335Z
-- Translation job ID: 86e50ade-b689-41b3-9ba9-6cce7f91106a
-- Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/EDW_TRIPS/SPs/Utility_Get_CreateEmptyCopy_SQL.sql
-- Translated from: SqlServer
-- Translated to: BigQuery

CREATE OR REPLACE PROCEDURE EDW_TRIPS_SUPPORT.Get_CreateEmptyCopy_SQL(IN table STRING, IN new_table_name STRING, INOUT params_in_sql_out STRING)
  BEGIN

/*
USE EDW_TRIPS 
GO
IF OBJECT_ID ('Utility.Get_CreateEmptyCopy_SQL', 'P') IS NOT NULL DROP PROCEDURE Utility.Get_CreateEmptyCopy_SQL 
GO

###################################################################################################################
Example:
-------------------------------------------------------------------------------------------------------------------
DECLARE @Params_In_SQL_Out VARCHAR(MAX) = 'No[]', @Table_Name VARCHAR(200)  = '[TollPlus].[TP_Customers]'
EXEC Utility.Get_CreateEmptyCopy_SQL @Table_Name, Null, @Params_In_SQL_Out OUTPUT 
===================================================================================================================
Proc Description: 
-------------------------------------------------------------------------------------------------------------------
This proc creating and returning SQL statement to create empty new table as full copy of metadata from source table
New table has the same Columns, Indexes, Distribution and Partition. Statistics is not included.

@Table_Name - Table name (with Schema) is example for copy
@New_Table_Name - Table name we need to creat empty. If empty or Null new name will be Table_Name + '_Copy'
@Params_In_SQL_Out - Param to return SQL statement. Can take some secondary parameters
	can include values: 	'No[],NoPrint'
===================================================================================================================
Change Log:
-------------------------------------------------------------------------------------------------------------------
CHG0037837			Andy	01/10/2020	New!
###################################################################################################################
*/

    DECLARE error STRING DEFAULT '';
    DECLARE params STRING DEFAULT coalesce(params_in_sql_out, '');
    DECLARE table_index STRING;
    IF table IS NULL THEN
      SET error = concat(error, 'Table name cannot be NULL');
    END IF;
    IF new_table_name IS NULL THEN
      SET error = concat(error, 'Target Table name cannot be NULL');
    END IF;
    SET params_in_sql_out = '';
    IF length(rtrim(error)) > 0 THEN
        SELECT error;
    ELSE
      BEGIN
        /*====================================== TESTING =======================================================================*/
        --DECLARE @Table_Name VARCHAR(4000) = '[TollPlus].[TP_Customers]', @New_Table_Name VARCHAR(200), @Params_In_SQL_Out VARCHAR(MAX) 
        /*====================================== TESTING =======================================================================*/

        DECLARE index INT64;
        SET table_index = concat(params, ',NoPrint');
        IF new_table_name IS NULL
         OR length(rtrim(new_table_name)) = 0 THEN
          SET new_table_name = concat(table, '_Copy');
        END IF;

        SET table_index = (
          select  concat("CLUSTER BY ", STRING_AGG(column_name, ",")) from EDW_TRIPS.INFORMATION_SCHEMA.COLUMNS c
              where lower(c.table_name)=lower(table) and clustering_ordinal_position IS NOT NULL
        );
        
        -- First we have to drop existing table
        SET params_in_sql_out = concat(params_in_sql_out, code_points_to_string(ARRAY[
          13
        ]), 'CREATE OR REPLACE TABLE EDW_TRIPS.', new_table_name, ' ', table_index, ' ', 'AS', code_points_to_string(ARRAY[
          13
        ]), 'SELECT *', code_points_to_string(ARRAY[
          13
        ]), 'FROM ', '[EDW_TRIPS.', table, ']', code_points_to_string(ARRAY[
          13
        ]), 'WHERE 1 = 2');
        IF strpos(params, 'No[]') > 0 THEN
          SET params_in_sql_out = replace(replace(params_in_sql_out, '[', ''), ']', '');
        END IF;
        IF strpos(params, 'NoPrint') = 0 THEN
            SELECT params_in_sql_out;
        END IF;
      END;
    END IF;
  END;
