CREATE OR REPLACE PROCEDURE `EDW_TRIPS_SUPPORT.Row_to_Row_Match_Item_90`(comparison_dataset_name STRING, dev_dataset_name STRING, table_name STRING, export_table STRING, primary_key STRING, excluded_columns STRING, ts_column1 STRING, ts_column2 STRING)
BEGIN
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

-- select APS_columns;
SET APS_columns= replace(APS_columns,ts_column1,"cast( FORMAT_TIMESTAMP('%Y-%m-%dT%H:%M:%S',"|| ts_column1 ||", 'UTC') as DATETIME) as "|| ts_column1 ||"");
SET APS_columns= replace(APS_columns,ts_column2,"cast( FORMAT_TIMESTAMP('%Y-%m-%dT%H:%M:%S', "|| ts_column2 ||",'UTC') as DATETIME) as "|| ts_column2 ||"");

-- SET APS_columns= replace(APS_columns,"edw_updateddate","cast( FORMAT_TIMESTAMP('%Y-%m-%dT%H:%M:%S', '''||aps_ts_columns||''') as DATETIME) as formatted_date");

-- Set Dev_columns=replace(Dev_columns,"thirdnoticedate","cast( thirdnoticedate as STRING) as thirdnoticedate");
-- Set Dev_columns=replace(Dev_columns,"legalactionpendingdate","cast( legalactionpendingdate as STRING) as legalactionpendingdate");
-- Set Dev_columns=replace(Dev_columns,"edw_updateddate","cast( '''||aps_ts_columns||''' as STRING) as formatted_date");
SET sql = '''
      WITH


        table_a AS (
          SELECT '''||APS_columns||''' FROM `'''||Comparison_Dataset_Name||'''.'''||table_name||'''`
        ),
        table_b AS (
          SELECT '''||Dev_columns||''' FROM `'''||Dev_Dataset_Name||'''.'''||table_name||'''`
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
    ''';
IF Export_table IS NOT NULL THEN
SET sql = concat('CREATE OR REPLACE TABLE ',Export_table,' AS ',sql);
ELSE
SET sql = concat(sql,' Limit 1000');
END IF;
EXECUTE IMMEDIATE sql;
end;