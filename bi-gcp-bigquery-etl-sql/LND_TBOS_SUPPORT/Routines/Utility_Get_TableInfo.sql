
CREATE OR REPLACE PROCEDURE LND_TBOS_SUPPORT.Get_TableInfo(IN table STRING, IN proc_name STRING, INOUT params_in_sql_out STRING)

  BEGIN
/*
USE LND_TBOS 
GO
IF OBJECT_ID ('Utility.Get_TableInfo', 'P') IS NOT NULL DROP PROCEDURE Utility.Get_TableInfo
GO

###################################################################################################################
Example:
-------------------------------------------------------------------------------------------------------------------
DECLARE @Params_In_SQL_Out VARCHAR(MAX) = 'Types,Alias,No[],NewTable:_NewTable'
EXEC Utility.Get_TableInfo 'dbo.Dim_Month', 'CreateTableAs,CreateStatistics,RenameTable', @Params_In_SQL_Out OUTPUT

DECLARE @Params_In_SQL_Out VARCHAR(MAX) = 'Types,Alias:Short,No[],NewSchema:Stage'
EXEC Utility.Get_TableInfo 'dbo.Dim_Month', 'Select,CreateTruncateTable', @Params_In_SQL_Out OUTPUT
===================================================================================================================
Proc Description: 
-------------------------------------------------------------------------------------------------------------------
This proc give you possibility to kick off several GET SQL procs from one call.

@Table_Name - Table name (with Schema) - table name for all actions you want to apply
@Proc_Name - List of the procs you want to use for the table you sent
@Params_In_SQL_Out - Param to return SQL statement. Can take some secondary parameters
	can include values: 	'Types,Alias:Short or Long or YourAlias,TitleCase,No[],NewTable:NewTableName,NewSchema:NewSchemaName,NoPrint'
	If NewTable or NewSchema is not chosen, it will be Schema.Table + '_New' by default
	If NewTable starts from '_' - it thinks it is a suffics to add to the table name
===================================================================================================================
Change Log:
-------------------------------------------------------------------------------------------------------------------
CHG0037837 Andy	01/10/2020	New!
CHG0038319 	Andy		2021-03-08  Changed CreateEmptySwitchTable to CreateEmptyCopy
###################################################################################################################
*/

  /*====================================== TESTING =======================================================================*/
	-- DECLARE @Table_Name = 'dbo.Dim_Month', @Proc_Name VARCHAR(100)  = 'Get_Select_String', @Params_In_SQL_Out VARCHAR(MAX) = 'Types,Alias:Short,No[],NewSchema:Stage'
	/*====================================== TESTING =======================================================================*/

    DECLARE error STRING DEFAULT '';
    DECLARE params STRING DEFAULT coalesce(params_in_sql_out, '');
    DECLARE dot1 INT64;
    DECLARE index INT64;
    DECLARE new_table_name STRING;
    DECLARE sql STRING;
    IF table IS NULL THEN
      SET error = concat(error, 'Table name cannot be NULL');
    END IF;
    SET params_in_sql_out = '';
    IF length(rtrim(error)) > 0 THEN
        SELECT error;
    ELSE
      IF proc_name IS NULL THEN
        SET proc_name = '';
      END IF;
      
      SET new_table_name = concat(table, '_New');

      SET params_in_sql_out = concat('-- Was called Get_TableInfo for Table ', table, code_points_to_string(ARRAY[
        13
      ]), code_points_to_string(ARRAY[
        10
      ]));
      SET params = replace(replace(params, ' ', ''), '\t', '');
      SET index=(
      SELECT
          coalesce(nullif(strpos(params, 'NewTable:'), 0), strpos(params, 'NewName:')) 
      );
      IF index > 0 THEN -- In this brackets only the table name can be we need to put in AS
        SET new_table_name = substr(params, greatest(CASE
          WHEN strpos(substr(params, index), ':') = 0 THEN 0
          ELSE strpos(substr(params, index), ':') + (CASE
            WHEN index < 1 THEN 1
            ELSE index
          END - 1)
        END + 1, 0), CASE
          WHEN CASE
            WHEN strpos(substr(params, index), ':') = 0 THEN 0
            ELSE strpos(substr(params, index), ':') + (CASE
              WHEN index < 1 THEN 1
              ELSE index
            END - 1)
          END + 1 < 1 THEN greatest(CASE
            WHEN strpos(substr(params, index), ':') = 0 THEN 0
            ELSE strpos(substr(params, index), ':') + (CASE
              WHEN index < 1 THEN 1
              ELSE index
            END - 1)
          END + 1 + (coalesce(nullif(CASE
            WHEN strpos(substr(params, index), ',') = 0 THEN 0
            ELSE strpos(substr(params, index), ',') + (CASE
              WHEN index < 1 THEN 1
              ELSE index
            END - 1)
          END, 0), length(rtrim(params)) + 1) - CASE
            WHEN strpos(substr(params, index), ':') = 0 THEN 0
            ELSE strpos(substr(params, index), ':') + (CASE
              WHEN index < 1 THEN 1
              ELSE index
            END - 1)
          END - 1 - 1), 0)
          ELSE coalesce(nullif(CASE
            WHEN strpos(substr(params, index), ',') = 0 THEN 0
            ELSE strpos(substr(params, index), ',') + (CASE
              WHEN index < 1 THEN 1
              ELSE index
            END - 1)
          END, 0), length(rtrim(params)) + 1) - CASE
            WHEN strpos(substr(params, index), ':') = 0 THEN 0
            ELSE strpos(substr(params, index), ':') + (CASE
              WHEN index < 1 THEN 1
              ELSE index
            END - 1)
          END - 1
        END);
        SET params = replace(replace(params, concat('NewTable:', new_table_name), ''), concat('NewName:', new_table_name), ''); -- If table include somehow one of the key word (like table, Type or Alias) - we have to remove it
        IF left(new_table_name, 1) = '_' THEN
          SET new_table_name = concat(table, new_table_name);
        END IF;
      END IF;

      IF proc_name LIKE '%Index%' THEN

        SET sql = (
          select  concat("CLUSTER BY ", STRING_AGG(column_name, ",")) from LND_TBOS.INFORMATION_SCHEMA.COLUMNS c
              where lower(c.table_name)=lower(table) and clustering_ordinal_position IS NOT NULL
        );

        SET params_in_sql_out = concat(params_in_sql_out, code_points_to_string(ARRAY[
          13
        ]), code_points_to_string(ARRAY[
          10
        ]), '--Index:', code_points_to_string(ARRAY[
          13
        ]), code_points_to_string(ARRAY[
          10
        ]), sql, code_points_to_string(ARRAY[
          13
        ]), code_points_to_string(ARRAY[
          10
        ]));
      END IF;
      
      IF proc_name LIKE '%Select%' THEN
        SET sql = concat(params, ',NoPrint');
        CALL LND_TBOS_SUPPORT.Get_Select_String(table, sql);
        SET params_in_sql_out = concat(params_in_sql_out, code_points_to_string(ARRAY[
          13
        ]), code_points_to_string(ARRAY[
          10
        ]), '--Select:', code_points_to_string(ARRAY[
          13
        ]), code_points_to_string(ARRAY[
          10
        ]), sql, code_points_to_string(ARRAY[
          13
        ]), code_points_to_string(ARRAY[
          10
        ]));
      END IF;
      IF proc_name LIKE '%CreateEmptyCopy%' THEN
        SET sql = concat(params, ',NoPrint');
        CALL LND_TBOS_SUPPORT.Get_CreateEmptyCopy_SQL(table, new_table_name, sql);
        SET params_in_sql_out = concat(params_in_sql_out, code_points_to_string(ARRAY[
          13
        ]), code_points_to_string(ARRAY[
          10
        ]), '--Create Epmty Copy:', code_points_to_string(ARRAY[
          13
        ]), code_points_to_string(ARRAY[
          10
        ]), sql, code_points_to_string(ARRAY[
          13
        ]), code_points_to_string(ARRAY[
          10
        ]));
      END IF;
      IF proc_name LIKE '%CreateTableAs%' THEN
        SET sql = concat(params, ',NoPrint');
        CALL LND_TBOS_SUPPORT.Get_CreateTableAs_SQL (table, new_table_name, sql);
        SET params_in_sql_out = concat(params_in_sql_out, code_points_to_string(ARRAY[
          13
        ]), code_points_to_string(ARRAY[
          10
        ]), '--Create Table As:', code_points_to_string(ARRAY[
          13
        ]), code_points_to_string(ARRAY[
          10
        ]), sql, code_points_to_string(ARRAY[
          13
        ]), code_points_to_string(ARRAY[
          10
        ]));
      END IF;
      
      IF proc_name NOT LIKE '%Index%'
       AND proc_name NOT LIKE '%Select%'
       AND proc_name NOT LIKE '%CreateEmptyCopy%'
       AND proc_name NOT LIKE '%CreateTableAs%' THEN
        SET params_in_sql_out = concat('Procedure named "', coalesce(proc_name, 'NULL'), '" was not found. Check proc names below:');
        
        SET params_in_sql_out = concat(params_in_sql_out, code_points_to_string(ARRAY[
          13
        ]), code_points_to_string(ARRAY[
          10
        ]), 'Index\t\t\t\t\t\t(returning Table INDEX String for using in CREATE Table statement)');
        
        SET params_in_sql_out = concat(params_in_sql_out, code_points_to_string(ARRAY[
          13
        ]), code_points_to_string(ARRAY[
          10
        ]), 'Select\t\t\t\t\t\t(returning the String with the list of fields delimited with comma for using in SELECT statement)');
        SET params_in_sql_out = concat(params_in_sql_out, code_points_to_string(ARRAY[
          13
        ]), code_points_to_string(ARRAY[
          10
        ]), 'CreateEmptyCopy\t\t\t(returning CREATE Empty Copy of the Table with "_New" suffix or the name in parameters)');
        SET params_in_sql_out = concat(params_in_sql_out, code_points_to_string(ARRAY[
          13
        ]), code_points_to_string(ARRAY[
          10
        ]), 'CreateTableAs\t\t\t\t(returning CREATE Table WITH(..) AS SELECT.. query)');
        
        SET params_in_sql_out = concat(params_in_sql_out, code_points_to_string(ARRAY[
          13
        ]), code_points_to_string(ARRAY[
          10
        ]), 'It is possible to call several procs at once, separate them with comma like <<CreateEmptyCopy, CreateTableAs>>');
      END IF;
      IF strpos(params, 'NoPrint') = 0 THEN
        SELECT params_in_sql_out;
      END IF;
    END IF;
  END;
