CREATE OR REPLACE PROCEDURE `EDW_TRIPS_SUPPORT.Get_Index_String`(table_name STRING, INOUT params_in_sql_out STRING)
BEGIN
/*

USE EDW_TRIPS
GO
IF OBJECT_ID ('Utility.Get_Index_String', 'P') IS NOT NULL DROP PROCEDURE Utility.Get_Index_String
GO
###################################################################################################################
Example:
-------------------------------------------------------------------------------------------------------------------
DECLARE @Params_In_SQL_Out VARCHAR(MAX) = 'No[]'
EXEC Utility.Get_Index_String 'dbo.Dim_Month', @Params_In_SQL_Out OUTPUT 
===================================================================================================================
Proc Description: 
-------------------------------------------------------------------------------------------------------------------
This proc creating and returning Index string for Create table statement, looks like 'CLUSTERED COLUMNSTORE INDEX' or 'CLUSTERED INDEX (Column1 ASC, Column2 DESC)'

@Table_Name - Name of the table to pick column from
@Params_In_SQL_Out - Param to return string. 
	-- can be: 	'No[],NoPrint'
===================================================================================================================
Change Log:
-------------------------------------------------------------------------------------------------------------------
CHG0037837			Andy	01/10/2020	New!
###################################################################################################################
*/

    DECLARE error STRING DEFAULT '';
    DECLARE params STRING DEFAULT coalesce(params_in_sql_out, '');
    DECLARE schema STRING;
    DECLARE table STRING;
    DECLARE table_index STRING DEFAULT 'CLUSTERED';
    IF table_name IS NULL THEN
			SET error = concat(error, 'Table name cannot be NULL');
    END IF;
    SET params_in_sql_out = '';
    IF length(rtrim(error)) > 0 THEN
      ## BigQuery does not support any equivalent for PRINT or LOG.
	  SELECT error;
    ELSE
      BEGIN
        DECLARE dot INT64;
        SET dot = strpos(table_name, '.');
       SET (schema,table)= (SELECT
            (CASE
              WHEN dot = 0 THEN 'EDW_TRIPS_dbo'
              ELSE replace(replace(replace(left(table_name, dot), '[', ''), ']', ''), '.', '')
            END ,
            CASE
              WHEN dot = 0 THEN replace(replace(table_name, '[', ''), ']', '')
              ELSE replace(replace(substr(table_name, greatest(dot + 1, 0), CASE
                WHEN dot + 1 < 1 THEN greatest(dot + 1 + (200 - 1), 0)
                ELSE 200
              END), '[', ''), ']', '')
            END ))
        ;
        /*SELECT
            i.type_desc AS __table_index
          FROM
            EDW_TRIPS.sys.tables AS t
            INNER JOIN EDW_TRIPS.sys.schemas AS s ON s.schema_id = t.schema_id
             AND s.name = schema
            INNER JOIN EDW_TRIPS.sys.indexes AS i ON i.object_id = t.object_id
          WHERE t.name = table
           AND i.index_id <= 1
        ;*/
        IF table_index = 'CLUSTERED' THEN
         SET params_in_sql_out = ( WITH cte AS (
            SELECT              
                u.column_name AS column_name,clustering_ordinal_position,
                row_number() OVER (ORDER BY clustering_ordinal_position desc) AS rn
              FROM
                region-us-south1.INFORMATION_SCHEMA.COLUMNS AS u
              WHERE u.table_name=table
			  AND u.table_schema=schema
			  AND coalesce(u.clustering_ordinal_position,0)> 0
          ), cte_joint AS (
            SELECT
                concat(cte1.column_name, coalesce(cte2.column_name, ''), coalesce(cte3.column_name, ''), coalesce(cte4.column_name, ''), coalesce(cte5.column_name, ''), coalesce(cte6.column_name, ''), coalesce(cte7.column_name, ''), coalesce( cte8.column_name, ''), coalesce(cte9.column_name, ''), coalesce(cte10.column_name, '')) AS index_coulumns
              FROM
               cte AS cte1
                LEFT OUTER JOIN cte AS cte2 ON cte2.rn = 2
                LEFT OUTER JOIN cte AS cte3 ON cte3.rn = 3
                LEFT OUTER JOIN cte AS cte4 ON cte4.rn = 4
                LEFT OUTER JOIN cte AS cte5 ON cte5.rn = 5
                LEFT OUTER JOIN cte AS cte6 ON cte6.rn = 6
                LEFT OUTER JOIN cte AS cte7 ON cte7.rn = 7
                LEFT OUTER JOIN cte AS cte8 ON cte8.rn = 8
                LEFT OUTER JOIN cte AS cte9 ON cte9.rn = 9
                LEFT OUTER JOIN cte AS cte10 ON cte10.rn = 10
              WHERE cte1.rn = 1
          )
          SELECT
              concat(table_index, ' BY  (', cte_joint.index_coulumns, ')') 
            FROM
              cte_joint
          LIMIT 1);
     /*   ELSEIF table_index = 'CLUSTERED COLUMNSTORE' THEN
          SET params_in_sql_out = concat(table_index, ' INDEX');*/
        ELSE
          SET params_in_sql_out = table_index;
        END IF;
        IF strpos(params, 'No[]') > 0 THEN
          SET params_in_sql_out = replace(replace(params_in_sql_out, '[', ''), ']', '');
        END IF;
        IF strpos(params, 'NoPrint') = 0 THEN
          CALL EDW_TRIPS_SUPPORT.longprint(params_in_sql_out);
        END IF;
      END;
    END IF;
  END;