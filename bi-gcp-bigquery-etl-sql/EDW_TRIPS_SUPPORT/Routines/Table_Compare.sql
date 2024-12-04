CREATE OR REPLACE PROCEDURE `EDW_TRIPS_SUPPORT.Table_Compare`( table_1 STRING, table_2 STRING , mismatch_table STRING, sort_key STRING, include_columns STRING, excluded_columns STRING , filter_condition STRING , table_1_alias STRING , table_2_alias STRING )
BEGIN
/*
#####################################################################################################
Proc Description: 
----------------------------------------------------------------------------------------------------
 Runs Row to Row Comparison on Table 
 table_1 				          : ( Required ) Table to Compare 
 table_2              		: ( Required ) Comparison Table Name
 mismatch_table        		: ( Optional ) Table to export Comparison results  When Not Provided , SP will Display mismatches max upto 1000  rows
 sort_key 					      : ( Optional ) Column name to use for ordering the results 
 include_columns			    : ( Optional ) Comma-separated list of Columns incase You want to Limit Compariosn to Limited columns only   When Not Provided it will use all Columns of the Table
 excluded_columns 			  : ( Optional ) Comma-separated list of columns to exclude from comparison
 filter_condition			    : ( Optional ) Where Condition , when want to Comapre a subset of data or in-case of Partiotned Table 
 table_1_alias            : ( Optional ) , Alias Name for Table 1
 table_2_alias            : ( Optional ) , Alias Name for Table 2
================================================================================================
Change Log:
--------------------------------------------------------------------------------------------
********    EGen        14-06-2024     New!
================================================================================================
Example:   
--------------------------------------------------------------------------------------------------
DECLARE table_1 STRING DEFAULT 'EDW_TRIPS.Fact_CustomerDailyBalance';
DECLARE table_2 STRING DEFAULT 'EDW_TRIPS_APS.Fact_CustomerDailyBalance';
DECLARE mismatch_table STRING DEFAULT 'Data_Validation.Fact_CustomerDailyBalance';
DECLARE sort_key STRING DEFAULT NULL;
DECLARE include_columns STRING DEFAULT NULL;
DECLARE excluded_columns STRING DEFAULT 'edw_updatedate';
DECLARE filter_condition STRING DEFAULT 'balancestartdate is not Null';
DECLARE table_1_alias STRING DEFAULT 'BQ';
DECLARE table_2_alias STRING DEFAULT 'APS';
CALL `EDW_TRIPS_SUPPORT.Table_Compare`(table_1, table_2, mismatch_table, sort_key, include_columns, excluded_columns, filter_condition, table_1_alias, table_2_alias);
#######################################################################################
*/

	DECLARE sql STRING;
	DECLARE select_columns STRING;
	DECLARE order_by_clause STRING;
	Declare  Filter_Clause STRING;
  Declare dataset_name STRING;
  Declare table_name STRING;

  
  IF table_1_alias is NULL 
  THEN
    SET table_1_alias = table_1;
  END IF;
  IF table_2_alias is NULL 
  THEN
    SET table_2_alias = table_2;
  END IF;

	SET  Filter_Clause =  IF(filter_condition is NOT Null , concat( " Where ", filter_condition) , "Where 1= 1" );
  SET dataset_name = SPLIT(table_1,'.')[0];
  SET table_name = SPLIT(table_1,'.')[1];

  BEGIN 
    -- Checking mandatory & Valid Inputs Conditions
    IF table_1 is NULL or table_2 is NULL
    Then 
      RAISE USING MESSAGE =  "Input Variables table_1 and table_2  are Required Inputs , Please Execute with a valid Input value " ;
    ELSEIF table_1 = table_2
    THEN 
      RAISE USING MESSAGE =  CONCAT("Compariosn Table and Main Table Can not be Same " , table_1 , " and " ,  table_2 ) ;
    END IF;

    Select CONCAT(" Comparing Table ",table_1 , " With " , table_2  );

	-- Generating List of Column to Compare based on include_columns and excluded_columns
	IF include_columns IS NOT NULL 
	THEN 
		Select "include_columns is not Null ";
		SET select_columns = include_columns;
	ELSE
		IF excluded_columns IS NULL 
		THEN
  			SET excluded_columns = "''"; 
		ELSE 
			SET excluded_columns = ( SELECT STRING_AGG(CONCAT("'", lower(trim(column_name)), "'"), ',') FROM UNNEST(SPLIT(excluded_columns, ',')) AS column_name);
		END IF;

		SET sql = ("SELECT string_agg(column_name ,',') as columns  FROM `" || dataset_name || ".INFORMATION_SCHEMA.COLUMNS` where lower(column_name) NOT IN ("||excluded_columns||") and lower(table_name) =lower('"|| table_name||"')");
		EXECUTE IMMEDIATE sql INTO select_columns;
  	END IF;

	SET order_by_clause = IF(sort_key IS NOT NULL, CONCAT("ORDER BY ", sort_key, ", 1"), "ORDER BY 2, 1");
	SET sql = '''
      WITH
        table_a AS (
          SELECT '''||select_columns||''' FROM `'''|| table_2 ||'''`
		  '''|| Filter_Clause ||'''
        ),
        table_b AS (
          SELECT '''||select_columns||''' FROM `'''|| table_1 ||'''`
		  '''|| Filter_Clause ||'''
        ),
        rows_mismatched AS (
          SELECT ' '''|| table_2_alias ||''' ' AS table_name, *
          FROM (
            SELECT * FROM table_a EXCEPT DISTINCT SELECT * FROM table_b 
          )
          UNION ALL
          SELECT ' '''||table_1_alias||''' ' AS table_name, *
          FROM (
            SELECT * FROM table_b EXCEPT DISTINCT SELECT * FROM table_a 
          )
        )
      SELECT *
      FROM rows_mismatched 
      '''|| order_by_clause ||'''
    ''';



    IF mismatch_table IS NOT NULL THEN
      SET sql = concat('CREATE OR REPLACE TABLE ',mismatch_table,' AS ',sql);
    ELSE
      SET sql = concat(sql,' Limit 1000');
    END IF;
    Select Concat("Final Mismatch Query : ",sql);
    EXECUTE IMMEDIATE sql;

    EXCEPTION WHEN ERROR THEN
      BEGIN
        DECLARE error_message STRING DEFAULT @@error.message;
        Select Concat("Error : ",error_message);
        RAISE USING MESSAGE = error_message;  -- Rethrow the error!
      END;
  END;
END;