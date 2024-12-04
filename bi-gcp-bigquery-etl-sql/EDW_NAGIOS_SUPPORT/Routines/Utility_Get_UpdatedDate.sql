CREATE OR REPLACE PROCEDURE `EDW_NAGIOS_SUPPORT.Get_UpdatedDate`(table_name STRING, OUT last_updated_date DATETIME)
BEGIN
/*
IF OBJECT_ID ('Utility.Get_UpdatedDate', 'P') IS NOT NULL DROP PROCEDURE Utility.Get_UpdatedDate
GO

###################################################################################################################
!!!!!!!!!  THIS PROCEDURE IS FOR EDW_NAGIOS Database ONLY, NOT FOR LND_TBOS  !!!!!!!!!!!
Example:
-------------------------------------------------------------------------------------------------------------------
DECLARE @Last_Updated_Date DATETIME2(3), @Table_Name VARCHAR(130)  = 'Finance.BankPayments', @Column_Name VARCHAR(130)  = 'LND_UpdateDate'
EXEC Utility.Get_UpdatedDate @Table_Name, @Column_Name, @Last_Updated_Date OUTPUT 
PRINT @Last_Updated_Date
===================================================================================================================
Proc Description: 
-------------------------------------------------------------------------------------------------------------------
This proc is getting the last update date for table in the Utility.LoadProcessControl table or from table itself (if there is no in utility)

@Table_Name - table name for wich new Updated date is getting
@Last_Updated_Date - returning parameter 
===================================================================================================================
Change Log:
-------------------------------------------------------------------------------------------------------------------
CHG0037837 Andy	01/10/2020	New!
CHG0038319 	Andy		2021-03-08  Changed to work based on LND_UpdateDate
###################################################################################################################
*/
    DECLARE fullname STRING;
    DECLARE dot INT64;
    DECLARE updatedatecolumn STRING;
    DECLARE table STRING;
    DECLARE schema STRING;
    SET fullname = replace(replace(table_name, '[', ''), ']', '');
    SET dot = strpos(table_name, '.');
    
    SET schema = CASE
                      WHEN dot = 0 THEN 'EDW_NAGIOS'
                      ELSE replace(replace(replace(left(table_name, dot), '[', ''), ']', ''), '.', '')
                    END ;
    SET table = CASE
                      WHEN dot = 0 THEN replace(replace(table_name, '[', ''), ']', '')
                      ELSE replace(replace(substr(table_name, greatest(dot + 1, 0), CASE
                        WHEN dot + 1 < 1 THEN greatest(dot + 1 + (200 - 1), 0)
                        ELSE 200
                      END), '[', ''), ']', '')
                    END;

    SET last_updated_date=( SELECT loadprocesscontrol.lastupdateddate FROM
        EDW_NAGIOS_SUPPORT.loadprocesscontrol
      WHERE loadprocesscontrol.tablename = fullname );
 
    IF last_updated_date IS NULL THEN

      SET updatedatecolumn = 
        (
          SELECT a.column_name 
        FROM
          (
              SELECT
                column_name,
                1 AS orderint
              FROM
                EDW_NAGIOS.INFORMATION_SCHEMA.COLUMNS
              WHERE
                table_name = table AND
                column_name = 'lnd_updatedate' AND
                table_schema = schema
            UNION ALL
              SELECT
                column_name,
                2 AS orderint
              FROM
                EDW_NAGIOS.INFORMATION_SCHEMA.COLUMNS
              WHERE
                table_name = table AND
                column_name = 'updateddate' AND
                table_schema = schema
            UNION ALL
              SELECT
                column_name,
                3 AS orderint
              FROM
                EDW_NAGIOS.INFORMATION_SCHEMA.COLUMNS
              WHERE
                table_name = table AND
                column_name = 'edw_updatedate' AND
                table_schema = schema
            
          ) AS a
      ORDER BY a.orderint
      LIMIT 1
        )
      ;
      IF updatedatecolumn IS NOT NULL THEN
        BEGIN
          EXECUTE IMMEDIATE "(Select MAX(@updatedatecolumn) FROM "||fullname||");" INTO last_updated_date USING updatedatecolumn=updatedatecolumn;

        EXCEPTION WHEN ERROR THEN
          SET last_updated_date = DATETIME '1990-01-01 00:00:00';
        END;
      END IF;
    END IF;
    IF last_updated_date IS NULL THEN
      SET last_updated_date = DATETIME '1990-01-01 00:00:00';
    END IF;
  END;