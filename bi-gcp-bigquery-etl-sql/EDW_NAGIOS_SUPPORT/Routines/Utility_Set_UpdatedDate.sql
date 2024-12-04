CREATE OR REPLACE PROCEDURE `EDW_NAGIOS_SUPPORT.Set_UpdatedDate`(table_name STRING, source_name STRING, OUT last_updated_date DATETIME)
BEGIN

/*
IF OBJECT_ID ('Utility.Set_UpdatedDate', 'P') IS NOT NULL DROP PROCEDURE Utility.Set_UpdatedDate
GO

###################################################################################################################
!!!!!!!!!  THIS PROCEDURE IS FOR EDW_NAGIOS Database ONLY, NOT FOR LND_TBOS  !!!!!!!!!!!
Example:
-------------------------------------------------------------------------------------------------------------------
If you have table from where have to get UpdatedDate  
EXEC Utility.Set_UpdatedDate 'Dim_Customer\TP_Customer_Addresses', 'LND_TBOS.TollPlus.TP_Customer_Addresses', NULL

 When you have date you have to set
DECLARE @Last_Updated_Date DATETIME2(3) = GETDATE()
EXEC Utility.Set_UpdatedDate 'Stage.TP_Trips', NULL, @Last_Updated_Date 
===================================================================================================================
Proc Description: 
-------------------------------------------------------------------------------------------------------------------
This proc is setting the last update date for table in the Utility.LoadProcessControl table
Can work differently = either taking sent parameter @Last_Updated_Date (exact date) or getting the last update date from sent source table

@Table_Name - table name for wich new Updated date is setting
@Source_Name - Source table from where the last UpdatedDate it should take using MAX(LND_UpdateDate)
@Last_Updated_Date - Exact date to set
===================================================================================================================
Change Log:
-------------------------------------------------------------------------------------------------------------------
CHG0037837 Andy	01/10/2020	New!
CHG0038319 	Andy		2021-03-08  Changed to work based on LND_UpdateDate
CHG0038458 Andy 03/30/2021 made it to clean update date if send NULL to both parameters
###################################################################################################################
*/
    DECLARE fullname STRING;
    DECLARE edw_updatedate DATETIME;

    SET fullname = substr(replace(replace(table_name, '[', ''), ']', ''),1,130);
    SET edw_updatedate = current_datetime();
    
    IF table_name IS NULL THEN
      SET table_name = substr(source_name,1,200);
    END IF;

    IF last_updated_date IS NULL AND nullif(source_name, '') IS NOT NULL
    THEN
      BEGIN 
         EXECUTE IMMEDIATE "(Select MAX(LND_UpdateDate) FROM "||Source_Name||");" INTO last_updated_date;
        EXCEPTION WHEN ERROR THEN SET last_updated_date = DATETIME '1990-01-01 00:00:00'; 
      END;
    END IF;

    DELETE FROM EDW_NAGIOS_SUPPORT.loadprocesscontrol WHERE loadprocesscontrol.tablename = fullname;
    -- If nothing sent (neither @Last_Updated_Date nor @Source_Name) we just removing Updated date
    IF last_updated_date IS NOT NULL THEN
      INSERT INTO EDW_NAGIOS_SUPPORT.loadprocesscontrol (tablename, lastupdateddate, edw_updatedate)
        VALUES (fullname, last_updated_date, edw_updatedate)
      ;
    END IF;
  END;