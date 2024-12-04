CREATE OR REPLACE PROCEDURE `LND_TBOS_SUPPORT.DeleteDuplicateRows`(table_name STRING, identifyingcolumns STRING, orderbystring STRING)
/*
USE EDW_TRIPS 
GO
IF OBJECT_ID ('Utility.DeleteDuplicateRows', 'P') IS NOT NULL DROP PROCEDURE Utility.DeleteDuplicateRows
GO

###################################################################################################################
Example:
-------------------------------------------------------------------------------------------------------------------
DECLARE @IdentifyingColumns VARCHAR(400) = '[TpTripID]', @OrderByString VARCHAR(MAX) = 'TripDate DESC',@Table_Name VARCHAR(200)  = '[dbo].[Fact_Transaction]'
EXEC Utility.DeleteDuplicateRows @Table_Name, @IdentifyingColumns, @OrderByString  

DECLARE @IdentifyingColumns VARCHAR(400) = '[CitationID],[SnapshotMonthID]', @OrderByString VARCHAR(MAX) = 'TransactionDate DESC',@Table_Name VARCHAR(200)  = '[dbo].[Fact_InvoiceAgingSnapshot]'
EXEC Utility.DeleteDuplicateRows @Table_Name, @IdentifyingColumns, @OrderByString  

SELECT * FROM Utility.ProcessLog WHERE LogSource = 'Utility.DeleteDuplicateRows' ORDER BY 1 DESC
===================================================================================================================
Proc Description: 
-------------------------------------------------------------------------------------------------------------------
This proc developed to find and Delete duplicates on the table

@Table_Name - Table name (with Schema) - table for get columns from
@IdentifyingColumns - List of the columns to uniqually identify rows in both tables.  Needed - can't be empty or Null. !!!!!!!!  EVERY COLUMN SHOULD BE IN [], Separator - up to you  !!!!!!!!!!!
@OrderByString - ORDER BY String to put to ROW_NUMBER() statement. Looks Like 'TripDate DESC, TPTripID ASC'. If empty it will create it from @IdentifyingColumns with DESC 
===================================================================================================================
Change Log:
-------------------------------------------------------------------------------------------------------------------
CHG0038817	Andy	05/03/2020	New!
###################################################################################################################
*/


  BEGIN
    DECLARE log_message STRING;
    DECLARE log_source STRING DEFAULT 'Utility.DeleteDuplicateRows';
    DECLARE log_start_date DATETIME;
    DECLARE error_message STRING;
    DECLARE sql_select STRING DEFAULT 'NoPrint';
    DECLARE table STRING;
    DECLARE schema STRING;
    DECLARE distribution STRING;
    DECLARE numofcolumns INT64;
    DECLARE indicat INT64 DEFAULT 1;
    DECLARE columnname STRING;
    DECLARE `where` STRING DEFAULT '';
    DECLARE delimiter_and STRING DEFAULT '';
    DECLARE order_by STRING;
    DECLARE uid_columns STRING DEFAULT '';
    DECLARE delimiter_comma STRING DEFAULT '';
    DECLARE trace_flag INT64 DEFAULT 1;
    DECLARE sql STRING;
    BEGIN
      DECLARE dot INT64;
      DECLARE row_count INT64;
      SET log_start_date = current_datetime();
      SET log_message = concat('Started Duplicate Rows cleanup in ', coalesce(table_name, r' ? table'));
      CALL LND_TBOS_SUPPORT.ToLog(log_source, log_start_date, log_message, 'I', NULL, NULL);
      --:: Validate input parameters
	  IF table_name IS NULL THEN
        SET error_message = concat(error_message, 'Table Name cannot be NULL');
      END IF;
      IF strpos(orderbystring, ')') > 0 THEN
        SET error_message = concat(error_message, 'Do not try to use SQL injection! It is forbidden!');
      END IF;
      IF length(rtrim(error_message)) > 0 THEN
        RAISE USING MESSAGE = 'error_message, 16, 1, ';
      END IF;
      SET dot = strpos(table_name, '.');
      SET (schema, table) = (
        SELECT
            STRUCT(CASE
              WHEN dot = 0 THEN 'dbo'
              ELSE replace(replace(replace(left(table_name, dot), '[', ''), ']', ''), '.', '')
            END AS `@schema`, CASE
              WHEN dot = 0 THEN replace(replace(table_name, '[', ''), ']', '')
              ELSE replace(replace(substr(table_name, greatest(dot + 1, 0), CASE
                WHEN dot + 1 < 1 THEN greatest(dot + 1 + (200 - 1), 0)
                ELSE 200
              END), '[', ''), ']', '')
            END AS `@table`)
        LIMIT 1
      );
      CALL LND_TBOS_SUPPORT.Get_Select_String(table_name, sql_select);
      
	  CREATE OR REPLACE TEMPORARY TABLE _SESSION.tablecolums
        AS
          SELECT
              c.column_name AS columnname,
              row_number() OVER (ORDER BY c.ordinal_position) AS rn
            FROM
                `LND_TBOS.INFORMATION_SCHEMA.COLUMNS` AS c
              
            WHERE c.table_name = table and CASE
              WHEN concat('[', c.name, ']') = '' THEN 0
              ELSE strpos(identifyingcolumns, concat('[', c.name, ']'))
            END > 0
      ;
      SET distribution = left(identifyingcolumns, CASE
        WHEN strpos(identifyingcolumns, ',') = 0 THEN length(rtrim(identifyingcolumns))
        ELSE strpos(identifyingcolumns, ',') - 1
      END);
      SET numofcolumns = (
        SELECT
            coalesce(any_value(subselect._u0040_numofcolumns), numofcolumns) AS _u0040_numofcolumns
          FROM
            (
              SELECT
                  max(`#table_columns`.rn) AS _u0040_numofcolumns
                FROM
                  _SESSION.tablecolums AS `#table_columns`
              LIMIT 1
            ) AS subselect
      );
      WHILE indicat <= numofcolumns DO
        SET columnname = (
          SELECT
              coalesce(any_value(subselect._u0040_columnname), columnname) AS _u0040_columnname
            FROM
              (
                SELECT
                    m.columnname AS _u0040_columnname
                  FROM
                    _SESSION.tablecolums AS m
                  WHERE m.rn = indicat
                LIMIT 1
              ) AS subselect
        );
        SET `where` = concat(`where`, delimiter_and, '[', table, '].[', columnname, '] = [Dups].[', columnname, ']');
        SET order_by = concat(order_by, delimiter_and, '[', columnname, '] DESC');
        SET uid_columns = concat(uid_columns, delimiter_comma, '[', columnname, ']');
        SET delimiter_and = ' AND ';
        SET delimiter_comma = ', ';
		SET indicat = indicat + 1;
        -- No target-dialect support for source-dialect-specific SET
      END WHILE;
      IF orderbystring IS NULL THEN
        SET orderbystring = order_by;
      END IF;
      IF trace_flag = 1 THEN
        SELECT
            `#table_columns`.*
          FROM
            _SESSION.tablecolums AS `#table_columns`
        ;
      END IF;
      IF trace_flag = 1 THEN
        SELECT
            distribution AS _u0040_distribution,
            `where` AS _u0040_where,
            order_by AS _u0040_order_by,
            uid_columns AS _u0040_uid_columns,
            numofcolumns AS _u0040_numofcolumns,
            indicat AS _u0040_indicat
        ;
      END IF;
      SET sql = concat('IF OBJECT_ID(\'Temp.', table, '_DUPS\') IS NOT NULL DROP TABLE Temp.', table, '_DUPS;\r\n\t\tCREATE TABLE Temp.', table, '_DUPS WITH (HEAP, DISTRIBUTION = HASH(', distribution, ')) AS \r\n\t\tSELECT ', uid_columns, ', count(1) CNT \r\n\t\tFROM ', schema, '.[', table, '] \r\n\t\tGROUP BY ', uid_columns, ' \r\n\t\tHAVING count(1) > 1');
      IF trace_flag = 1 THEN
	  	select sql;
        --CALL utility.longprint(sql);
      END IF;
      EXECUTE IMMEDIATE sql;
      SET log_message = concat('Loaded Temp.', table, '_DUPS with duplicate keys');
      CALL LND_TBOS_SUPPORT.ToLog(log_source, log_start_date, log_message, 'I', -1, -1);
      SET sql = concat('IF OBJECT_ID(\'Temp.', table, '_TO_INSERT\') IS NOT NULL DROP TABLE Temp.', table, '_TO_INSERT;\r\n\t\tCREATE TABLE Temp.', table, '_TO_INSERT WITH (HEAP, DISTRIBUTION = HASH(', distribution, ')) AS --EXPLAIN\r\n\t\tSELECT \r\n\t\t\t*\r\n\t\tFROM (\r\n\t\t\tSELECT \r\n\t\t\t\t', sql_select, ' \r\n\t\t\t\t, ROW_NUMBER() OVER (PARTITION BY ', uid_columns, ' ORDER BY ', orderbystring, ') RN\r\n\t\t\tFROM ', schema, '.[', table, '] AS [', table, '] WHERE EXISTS (SELECT 1 FROM Temp.', table, '_DUPS AS Dups WHERE ', `where`, ')\r\n\t\t) A\t');
      IF trace_flag = 1 THEN
	  	select sql;
        --CALL utility.longprint(sql);
      END IF;
      BEGIN
        EXECUTE IMMEDIATE sql;
      EXCEPTION WHEN ERROR THEN
        SET error_message = concat('Check out your input parameters! You have got an error! I assume you sent the wrong @OrderByString! Error massage: ', @@error.message);
        RAISE USING MESSAGE = 'error_message, 16, 1, ';
      END;
      SET log_message = concat('Loaded Temp.', table, '_TO_INSERT with duplicate keys');
      CALL LND_TBOS_SUPPORT.ToLog(log_source, log_start_date, log_message, 'I', -1, -1);
      SET sql = concat('\r\n\t\tDELETE \r\n\t\tFROM ', schema, '.[', table, ']\r\n\t\tWHERE EXISTS (SELECT 1 FROM Temp.', table, '_DUPS AS Dups WHERE ', `where`, ')\r\n\r\n\t\tINSERT INTO ', schema, '.[', table, ']\r\n\t\tSELECT ', sql_select, '\r\n\t\tFROM Temp.', table, '_TO_INSERT\r\n\t\tWHERE RN = 1');
      IF trace_flag = 1 THEN
	  	select sql;
        -- CALL utility.longprint(sql);
      END IF;
      EXECUTE IMMEDIATE sql;
      SET log_message = concat('Deleted all rows related to duplicate keys from ', schema, '.', table, ' and inserted unique rows!');
      CALL LND_TBOS_SUPPORT.ToLog(log_source, log_start_date, log_message, 'I', -1, -1);
      IF trace_flag = 1 THEN
        SET sql = concat('\r\n\t\t\tSELECT TOP 1000 \'Dup Before\' Result, *\r\n\t\t\tFROM Temp.', table, '_TO_INSERT \r\n\t\t\tORDER BY ', uid_columns, ', RN ASC');
        EXECUTE IMMEDIATE sql;
        SET sql = concat('SELECT \'Dup After\' Result,', uid_columns, ', count(1) DupRowCount \r\n\t\t\tFROM ', schema, '.[', table, '] \r\n\t\t\tGROUP BY ', uid_columns, ' \r\n\t\t\tHAVING count(1) > 1');
        EXECUTE IMMEDIATE sql;
      END IF;
      CALL LND_TBOS_SUPPORT.ToLog(log_source, log_start_date, 'Completed Duplicate Rows cleanup', 'I', NULL, NULL);
    EXCEPTION WHEN ERROR THEN
      SET error_message_0 = @@error.message;
      CALL LND_TBOS_SUPPORT.ToLog(`@log_source`, `@log_start_date`, `@error_message`, 'E', NULL, NULL);
      RAISE USING MESSAGE = '';  -- Rethrow the error!
    END;
  END;
