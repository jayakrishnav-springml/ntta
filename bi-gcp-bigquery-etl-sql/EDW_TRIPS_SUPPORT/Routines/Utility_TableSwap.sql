CREATE OR REPLACE PROCEDURE EDW_TRIPS_SUPPORT.TableSwap(source_table_name STRING, target_table_name STRING)
BEGIN
/*
###################################################################################################################
Purpose: Change New Table to Main Table. Source Table becomes Target Table!
Note   : Source and Target tables should have same table names but different schema names for schema transfer to work
-------------------------------------------------------------------------------------------------------------------
Change Log:
-------------------------------------------------------------------------------------------------------------------
CHG0000000	Shankar	2020-08-12	New!
-------------------------------------------------------------------------------------------------------------------
Example:
-------------------------------------------------------------------------------------------------------------------
EXEC Utility.TableSwap 'dbo.Dim_CollectionStatus_NEW', 'dbo.Dim_CollectionStatus'
###################################################################################################################
*/

    DECLARE log_message STRING;
    DECLARE dot1 INT64;
    DECLARE dot2 INT64;
    DECLARE source_schema STRING DEFAULT '';
    DECLARE target_schema STRING DEFAULT '';
    DECLARE source_table STRING DEFAULT '';
    DECLARE target_table STRING DEFAULT '';
    DECLARE sql STRING;
    DECLARE trace_flag INT64 DEFAULT 0;
    BEGIN
      DECLARE log_source STRING DEFAULT coalesce(target_table_name, source_table_name, 'NULL');
      DECLARE log_start_date DATETIME DEFAULT current_datetime();
      DECLARE row_count INT64;
      IF source_table_name IS NULL THEN
        SET log_message = '@Source_Table_Name param is NULL';
      END IF;
      IF target_table_name IS NULL THEN
        SET log_message = concat(coalesce(concat(log_message, ', '), ''), '@Target_Table_Name param is NULL');
      END IF;
      IF source_table_name = target_table_name THEN
        SET log_message = concat('Source table and target table names are identical! Transfer ', replace(replace(source_table_name, '[', ''), ']', ''), ' to ', replace(replace(target_table_name, '[', ''), ']', ''), r'?');
      END IF;
      IF source_table_name IS NULL
       OR target_table_name IS NULL
       OR source_table_name = target_table_name THEN
        RAISE USING MESSAGE = '51000, log_message, 1, ';
      END IF;
      SET dot1 = strpos(source_table_name, '.');
      SET dot2 = strpos(target_table_name, '.');
      IF dot1 = 0 THEN
        SELECT
            'dbo' AS __source_schema,
            replace(replace(source_table_name, '[', ''), ']', '') AS __source_table
        ;
      ELSE
        SELECT
            left(source_table_name, dot1 - 1) AS __source_schema,
            replace(replace(substr(source_table_name, greatest(dot1 + 1, 0), CASE
              WHEN dot1 + 1 < 1 THEN greatest(dot1 + 1 + (100 - 1), 0)
              ELSE 100
            END), '[', ''), ']', '') AS __source_table
        ;
      END IF;
      IF dot2 = 0 THEN
        SELECT
            'dbo' AS __target_schema,
            replace(replace(target_table_name, '[', ''), ']', '') AS __target_table
        ;
      ELSE
        SELECT
            left(target_table_name, dot2 - 1) AS __target_schema,
            replace(replace(substr(target_table_name, greatest(dot2 + 1, 0), CASE
              WHEN dot2 + 1 < 1 THEN greatest(dot2 + 1 + (100 - 1), 0)
              ELSE 100
            END), '[', ''), ']', '') AS __target_table
        ;
      END IF;
      IF source_schema <> target_schema
       AND source_table = target_table THEN
        SET sql = concat(code_points_to_string(ARRAY[
          9
        ]), code_points_to_string(ARRAY[
          9
        ]), 'IF OBJECT_ID(\'Old.', target_table, '\',\'U\') IS NOT NULL\t\tDROP TABLE Old.', target_table, code_points_to_string(ARRAY[
          13
        ]), code_points_to_string(ARRAY[
          10
        ]), code_points_to_string(ARRAY[
          9
        ]), code_points_to_string(ARRAY[
          9
        ]), 'IF OBJECT_ID(\'', target_table_name, '\',\'U\') IS NOT NULL\t\tALTER SCHEMA Old TRANSFER OBJECT::', target_table_name, ' ## Move existing table to Old schema', code_points_to_string(ARRAY[
          13
        ]), code_points_to_string(ARRAY[
          10
        ]), code_points_to_string(ARRAY[
          9
        ]), code_points_to_string(ARRAY[
          9
        ]), 'IF OBJECT_ID(\'', source_table_name, '\',\'U\') IS NOT NULL\t\tALTER SCHEMA ', target_schema, ' TRANSFER OBJECT::', source_table_name, '## Transfer schema ', code_points_to_string(ARRAY[
          13
        ]), code_points_to_string(ARRAY[
          10
        ]), code_points_to_string(ARRAY[
          9
        ]), code_points_to_string(ARRAY[
          9
        ]), 'IF OBJECT_ID(\'Old.', target_table, '\',\'U\') IS NOT NULL\t\tDROP TABLE Old.', target_table);
        IF trace_flag = 1 THEN
          ## BigQuery does not support any equivalent for PRINT or LOG.
        END IF;
        EXECUTE IMMEDIATE sql;
      ELSEIF source_schema = target_schema
       AND source_table <> target_table THEN
        SET sql = concat(code_points_to_string(ARRAY[
          9
        ]), code_points_to_string(ARRAY[
          9
        ]), 'IF OBJECT_ID(\'Old.', target_table, '\',\'U\') IS NOT NULL\t\tDROP TABLE Old.', target_table, code_points_to_string(ARRAY[
          13
        ]), code_points_to_string(ARRAY[
          10
        ]), code_points_to_string(ARRAY[
          9
        ]), code_points_to_string(ARRAY[
          9
        ]), 'IF OBJECT_ID(\'', target_table_name, '\',\'U\') IS NOT NULL\t\tALTER SCHEMA Old TRANSFER OBJECT::', target_table_name, ' ## Move existing table to Old schema', code_points_to_string(ARRAY[
          13
        ]), code_points_to_string(ARRAY[
          10
        ]), code_points_to_string(ARRAY[
          9
        ]), code_points_to_string(ARRAY[
          9
        ]), 'IF OBJECT_ID(\'', source_table_name, '\',\'U\') IS NOT NULL\t\tRENAME OBJECT::', source_table_name, ' TO ', target_table, ' ## Rename table', code_points_to_string(ARRAY[
          13
        ]), code_points_to_string(ARRAY[
          10
        ]), code_points_to_string(ARRAY[
          9
        ]), code_points_to_string(ARRAY[
          9
        ]), 'IF OBJECT_ID(\'Old.', target_table, '\',\'U\') IS NOT NULL\t\tDROP TABLE Old.', target_table);
        IF trace_flag = 1 THEN
          ## BigQuery does not support any equivalent for PRINT or LOG.
        END IF;
        EXECUTE IMMEDIATE sql;
      ELSEIF source_schema <> target_schema
       AND source_table <> target_table THEN
        SET sql = concat(code_points_to_string(ARRAY[
          9
        ]), code_points_to_string(ARRAY[
          9
        ]), 'IF OBJECT_ID(\'Old.', target_table, '\',\'U\') IS NOT NULL\t\tDROP TABLE Old.', target_table, code_points_to_string(ARRAY[
          13
        ]), code_points_to_string(ARRAY[
          10
        ]), code_points_to_string(ARRAY[
          9
        ]), code_points_to_string(ARRAY[
          9
        ]), 'IF OBJECT_ID(\'', target_table_name, '\',\'U\') IS NOT NULL\t\tALTER SCHEMA Old TRANSFER OBJECT::', target_table_name, ' ## Move existing table to Old schema', code_points_to_string(ARRAY[
          13
        ]), code_points_to_string(ARRAY[
          10
        ]), code_points_to_string(ARRAY[
          9
        ]), code_points_to_string(ARRAY[
          9
        ]), 'IF OBJECT_ID(\'', source_schema, '.', target_table, '\',\'U\') IS NOT NULL\t\tDROP TABLE ', source_schema, '.', target_table, ' ## Clear the way for rename before schema transfer', code_points_to_string(ARRAY[
          13
        ]), code_points_to_string(ARRAY[
          10
        ]), code_points_to_string(ARRAY[
          9
        ]), code_points_to_string(ARRAY[
          9
        ]), 'IF OBJECT_ID(\'', source_table_name, '\',\'U\') IS NOT NULL\t\tRENAME OBJECT::', source_table_name, ' TO ', target_table, ' ## Rename. Same table names, different schema names in the end', code_points_to_string(ARRAY[
          13
        ]), code_points_to_string(ARRAY[
          10
        ]), code_points_to_string(ARRAY[
          9
        ]), code_points_to_string(ARRAY[
          9
        ]), 'IF OBJECT_ID(\'', source_schema, '.', target_table, '\',\'U\') IS NOT NULL\t\tALTER SCHEMA ', target_schema, ' TRANSFER OBJECT::', source_schema, '.', target_table, ' ## Transfer schema', code_points_to_string(ARRAY[
          13
        ]), code_points_to_string(ARRAY[
          10
        ]), code_points_to_string(ARRAY[
          9
        ]), code_points_to_string(ARRAY[
          9
        ]), 'IF OBJECT_ID(\'Old.', target_table, '\',\'U\') IS NOT NULL\t\tDROP TABLE Old.', target_table);
        IF trace_flag = 1 THEN
          ## BigQuery does not support any equivalent for PRINT or LOG.
        END IF;
        EXECUTE IMMEDIATE sql;
      ELSE
        SET log_message = concat('Cannot swap table ', replace(replace(source_table_name, '[', ''), ']', ''), ' to ', replace(replace(target_table_name, '[', ''), ']', ''));
        RAISE USING MESSAGE = '51000, log_message, 1, ';
      END IF;
    EXCEPTION WHEN ERROR THEN
      BEGIN
        DECLARE error_message STRING DEFAULT concat('Utility.TableSwap Error: ', @@error.message);
        ##CALL utility.tolog(`@log_source`, `@log_start_date`, error_message, 'E', CAST(NULL as INT64), CAST(NULL as STRING));
        RAISE USING MESSAGE = error_message;
      END;
    END;
    
/*
-- Developer Testing Zone 

EXEC Utility.TableSwap 'New.Dim_CollectionStatus', 'dbo.Dim_CollectionStatus'
EXEC Utility.TableSwap null, 'dbo.Dim_CollectionStatus'
EXEC Utility.TableSwap 'New.Dim_CollectionStatus', null
EXEC Utility.TableSwap null, null
EXEC Utility.TableSwap 'New.Dim_CollectionStatus', 'New.Dim_CollectionStatus'

EXEC Utility.FromLog 'Dim_CollectionStatus', 1;
*/

  END;