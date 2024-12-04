CREATE OR REPLACE PROCEDURE `EDW_TRIPS_SUPPORT.Row_to_Row_Match_Fact_Invoice`(comparison_dataset_name STRING, dev_dataset_name STRING, table_name STRING, export_table STRING, primary_key STRING, excluded_columns STRING, filter_condition STRING)
BEGIN
/*
#####################################################################################################
Proc Description: 
----------------------------------------------------------------------------------------------------
 Runs Row to Row Compariosn on Table 
 comparison_dataset_name : Dataset Name for Compariosn Data 
 dev_dataset_name : Dataset Name where table is created using Stored Procedure 
 table_name : Table to Compare
 primary_key :
================================================================================================
Change Log:
--------------------------------------------------------------------------------------------
********    EGen        26-04-2024     New!
================================================================================================
Example:   
--------------------------------------------------------------------------------------------------
EXEC 

#######################################################################################
*/
  DECLARE sql STRING;
  DECLARE APS_columns STRING;
  DECLARE Dev_columns STRING;
  DECLARE order_by_clause STRING;

IF excluded_columns IS NULL THEN
  SET excluded_columns = "''"; 
ELSE
  SET excluded_columns = (
      SELECT STRING_AGG(CONCAT("'", trim(column_name), "'"), ',')
      FROM UNNEST(SPLIT(excluded_columns, ',')) AS column_name
  );
  
  END IF;

SET sql = ("SELECT string_agg(column_name ,',') as columns  FROM `" || comparison_dataset_name || ".INFORMATION_SCHEMA.COLUMNS` where column_name NOT IN ("||excluded_columns||") and lower(table_name) =lower('"|| table_name||"')");
EXECUTE IMMEDIATE sql INTO APS_columns;

SET sql = ("SELECT string_agg(column_name ,',') as columns  FROM `" || dev_dataset_name || ".INFORMATION_SCHEMA.COLUMNS` where column_name NOT IN ("||excluded_columns||") and lower(table_name) =lower('"|| table_name||"')");
EXECUTE IMMEDIATE sql INTO Dev_columns;
SET order_by_clause = IF(primary_key IS NOT NULL, CONCAT("ORDER BY ", primary_key, ", 1"), "ORDER BY 2, 1");

if filter_condition is null 
  then
  set filter_condition="1=1";
end if;
  SET sql = '''
      WITH
        table_a AS (
          SELECT '''||APS_columns||''' FROM `'''||Comparison_Dataset_Name||'''.'''||table_name||'''` WHERE '''||filter_condition||'''
        ),
        table_b AS (
          SELECT '''||Dev_columns||''' FROM `'''||Dev_Dataset_Name||'''.'''||table_name||'''` WHERE '''||filter_condition||'''
        ),
        rows_mismatched AS (
          SELECT 'APS' AS table_name, *
          FROM (
            SELECT * FROM table_a EXCEPT DISTINCT SELECT * FROM table_b 
          )
          UNION ALL
          SELECT 'Dev' AS table_name, *
          FROM (
            SELECT * FROM table_b EXCEPT DISTINCT SELECT * FROM table_a 
          )
        )
      SELECT *
      FROM rows_mismatched 
      '''|| order_by_clause ||'''
    ''';

IF Export_table IS NOT NULL THEN
SET sql = concat('CREATE OR REPLACE TABLE ',Export_table,' AS ',sql);
ELSE
SET sql = concat(sql,' Limit 1000');
END IF;
  EXECUTE IMMEDIATE sql;
END;