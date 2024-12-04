CREATE OR REPLACE PROCEDURE LND_TBOS_SUPPORT.LandingDataTransferAfterSSIS(tablelist STRING, loadprocessid INT64)
BEGIN
/*
IF OBJECT_ID ('Utility.LandingDataTransferAfterSSIS', 'P') IS NOT NULL DROP PROCEDURE Utility.LandingDataTransferAfterSSIS  
GO

###################################################################################################################
Example:
-------------------------------------------------------------------------------------------------------------------
EXEC Utility.LandingDataTransferAfterSSIS '[Finance].[Overpayments]', 0
EXEC Utility.LandingDataTransferAfterSSIS '', 0
EXEC Utility.FromLog '', 1

===================================================================================================================
Proc Description: 
-------------------------------------------------------------------------------------------------------------------
This proc used as a second step for SSIS load process and moving all loaded changes from Stage tables to Production tables. It can call other procs.


@TableList - can be epmty or having table list, devided by comma. Every table should consist of Schema name and Table name.
@LoadProcessID is used to parallelise load process - Do not use it for Full load - can stuck and block everything because of Schema tranfer object block!!!
===================================================================================================================
Change Log:
-------------------------------------------------------------------------------------------------------------------
CHG0037837	Andy		12/31/2020		New!
CHG0038290	Andy		3/3/2021		To keep Deleted Rows while doing full load in Landing
CHG0043566	Sagarika	8/23/2023		Preserve Archived Rows while doing full load in Landing
CHG0043621	Shankar		9/17/2023		1. Organized all the sequence of steps and added ProcessLog for each step to help 
										   with prod issue research. Removed all dead code.
										2. Alert main table data loss if stage table has 0 I rows and exit
										3. If deleted/archived rows are already present in the full load stage table, they must
										   be inserted by previous Landing Data Transfer run which either failed or stopped.
										   Reinserting them again will only bring duplicate rows.
										4. Drop any existing Stats on stage table before creating all Stats. Create Statistics 
										   fail if there is already an existing Statistic with the same name on the table.
										5. Fixed blank INDEX string in the output of Utility.Get_CreateEmptyCopy_SQL resulting in error.
										6. Backup SSISLoadCheck data before deleting for research. 
###################################################################################################################
*/

  /*====================================== TESTING =======================================================================*/
	##DECLARE @TableList VARCHAR(4000), @LoadProcessID INT 
	/*====================================== TESTING =======================================================================*/


    DECLARE startdate DATETIME;
    DECLARE logdate DATETIME;
    DECLARE num_of_columns INT64;
    DECLARE indicat INT64 DEFAULT 1;
    
    DECLARE row_count INT64 DEFAULT 0;
    DECLARE rowcnt INT64;
    DECLARE step STRING;
    DECLARE errors INT64;
    DECLARE tablecount INT64 DEFAULT 0;


    DECLARE maintablename STRING;
    DECLARE logmessage STRING;
    DECLARE updateproc STRING;
    DECLARE trace_flag INT64 DEFAULT 1;
    DECLARE nsql STRING;
    DECLARE parmdefinition STRING;
    DECLARE uid_columns STRING;
    DECLARE isfullload INT64 DEFAULT 0;
    
    DECLARE stagetablename STRING;
    DECLARE stagetablerowcount_i INT64 DEFAULT 0;
    DECLARE stagetablerowcount_d_a INT64 DEFAULT 0;
    DECLARE maintablerowcount_i_u INT64 DEFAULT 0;
    DECLARE maintablerowcount_d_a INT64 DEFAULT 0;
    DECLARE query STRING;
    DECLARE statssql STRING;
    DECLARE renamesql STRING;
    DECLARE runafterproc STRING;
    
    DECLARE schemaname STRING;
    DECLARE tablename STRING;
    DECLARE newtablename STRING;
    DECLARE updateddatecolumn STRING;
    DECLARE distributionstring STRING;
    DECLARE columnsstring STRING;
    DECLARE wherestring STRING;
    DECLARE sql_new_set STRING;
    DECLARE indexstring STRING;
    DECLARE deletesql STRING;
    DECLARE insertsql STRING;
    DECLARE useupdateddate INT64 DEFAULT 1;
    DECLARE usepartition INT64 DEFAULT 0;

    IF tablelist IS NULL THEN
      SET tablelist = '';
    END IF;
    IF loadprocessid IS NULL THEN
      SET loadprocessid = 0;
    END IF;

    SET tablelist = replace(replace(replace(replace(replace(tablelist, '[', ''), ']', ''), ' ', ''), code_points_to_string(ARRAY[
      9
    ]), ''), code_points_to_string(ARRAY[
      13
    ]), '');

    IF length(rtrim(tablelist)) > 0 THEN
      SET tablelist = concat(',', tablelist, ',');
    END IF;

    SET startdate = current_datetime();
    SET logdate = current_datetime();
    
    set logmessage = ( SELECT
        concat('Started for ', CASE
          WHEN tablelist = '' THEN 'all tables'
          ELSE concat('table list: ', tablelist)
        END, CASE
          WHEN loadprocessid = 0 THEN ' for all ProcessIDs'
          ELSE concat(' for ProcessID = ', substr(concat(CAST(loadprocessid as STRING), ' '), 1, 1))
        END)) ;

    ## Commenting ToLog , Replacing it with Select to Log Details while Execution 
    ## CALL utility.tolog('Utility.LandingDataTransferAfterSSIS', logdate, logmessage, 'I', CAST(NULL as INT64), CAST(NULL as STRING));
	Select 'LND_TBOS_SUPPORT.LandingDataTransferAfterSSIS', logdate, logmessage, 'I', CAST(NULL as INT64), CAST(NULL as STRING);
	
    
    /*====================================== TESTING =======================================================================*/
	##SELECT * FROM Utility.[TableLoadParameters]
	/*====================================== TESTING =======================================================================*/
    CREATE OR REPLACE TEMP TABLE _SESSION.cw_local_tmp_loadtable
      AS
        WITH cte_last_loads AS (
          ## Need find those tables, where last load ssis is finished but Load after ssis is not done yet
		  ## Its only one row for each table could be with LoadStep = 'S:3'
		SELECT
              ssisloadcheck.loadsource,
              ssisloadcheck.loaddate,
              row_count,
              CASE
                WHEN ssisloadcheck.loadinfo LIKE 'Step 2: SSIS Load finished' 
                THEN 1 ELSE 0 END AS isfullload
            FROM LND_TBOS_SUPPORT.ssisloadcheck
            WHERE ssisloadcheck.loadstep = 'S:3'
             AND row_count > 0
        )
        ,
         cte_tableloadparameters
         AS 
         (
          SELECT
              l.loaddate,
              l.row_count,
              t.schemaname,
              t.tablename,
              t.fullname,
              t.stagetablename,
              t.useupdateddate,
              t.uid_columns,
              t.usepartition,
              coalesce(t.runafterproc, '') AS runafterproc,
              t.distributionstring,
              t.statssql,
              t.deletesql,
              t.insertsql,
              t.columnsstring,
              t.wherestring,
              t.renamesql,
              coalesce(t.updateproc, '') AS updateproc,
              t.rowcnt,
              t.indexstring,
              t.updateddatecolumn,
              l.isfullload,
              row_number() OVER (PARTITION BY l.loadsource ORDER BY l.loaddate DESC) AS filterrn
            FROM
              cte_last_loads AS l
              INNER JOIN LND_TBOS_SUPPORT.tableloadparameters AS t ON ltrim(rtrim(l.loadsource)) = t.fullname
            WHERE (tablelist = ''
             OR tablelist LIKE concat('%,', t.fullname, ',%'))
             AND (loadprocessid = 0
             OR t.loadprocessid = loadprocessid)
             AND t.active = 1
        )
        SELECT
            cte_tableloadparameters.loaddate,
            cte_tableloadparameters.row_count,
            cte_tableloadparameters.schemaname,
            cte_tableloadparameters.tablename,
            cte_tableloadparameters.fullname,
            cte_tableloadparameters.stagetablename,
            cte_tableloadparameters.useupdateddate,
            cte_tableloadparameters.uid_columns,
            cte_tableloadparameters.usepartition,
            cte_tableloadparameters.runafterproc,
            cte_tableloadparameters.distributionstring,
            cte_tableloadparameters.statssql,
            cte_tableloadparameters.deletesql,
            cte_tableloadparameters.insertsql,
            cte_tableloadparameters.columnsstring,
            cte_tableloadparameters.wherestring,
            cte_tableloadparameters.renamesql,
            cte_tableloadparameters.updateproc,
            cte_tableloadparameters.rowcnt,
            cte_tableloadparameters.indexstring,
            cte_tableloadparameters.updateddatecolumn,
            cte_tableloadparameters.isfullload,
            row_number() OVER (ORDER BY cte_tableloadparameters.fullname) AS rn
          FROM
            cte_tableloadparameters
          WHERE cte_tableloadparameters.filterrn = 1
    ;

    /*====================================== TESTING =======================================================================*/
	##SELECT * FROM #LoadTable
	/*====================================== TESTING =======================================================================*/


    set num_of_columns = ( SELECT max(rn) AS num_of_columns FROM  _SESSION.cw_local_tmp_loadtable );

    WHILE indicat <= num_of_columns DO
    BEGIN
		 set ( schemaname  , tablename , maintablename , isfullload , row_count , 
		 rowcnt , stagetablename , newtablename ,uid_columns , usepartition , columnsstring , distributionstring,
		 indexstring , wherestring , statssql , deletesql , insertsql , useupdateddate , updateddatecolumn ,
		 updateproc ,runafterproc ) = 
		 
		 ( SELECT
           schemaname  ,
           tablename  ,
           fullname  ,
           isfullload  ,
           row_count  ,
           rowcnt  ,
           stagetablename  ,
          concat( fullname, '_New')  ,
           uid_columns  ,
           usepartition  ,
           columnsstring  ,
           distributionstring  ,
           indexstring  ,
           wherestring  ,
           statssql  ,
           deletesql  ,
           insertsql  ,
          CASE
            WHEN  isfullload = 1 THEN 0
            ELSE  useupdateddate
          END  ,
           updateddatecolumn  ,
           updateproc  ,
           runafterproc  
        FROM
          _SESSION.cw_local_tmp_loadtable 
        WHERE  rn = indicat
     );
      
      ##BigQuery does not support any equivalent for PRINT or LOG.
	  ##Replacing it with Select to Log Details while Execution 
      IF trace_flag = 1  THEN
        ##Lets see this all the time, not only when we test it.
		Select Concat('Loading table: ' , maintablename);
	  END IF;
		   
	  ##Replacing ToLog with Select to Log Details while Execution 
      ## CALL utility.tolog(maintablename, startdate, 'Step 3: Load after SSIS Started', 'I', CAST(NULL as INT64), CAST(NULL as STRING));
	  Select maintablename, startdate, 'Step 3: Load after SSIS Started', 'I', CAST(NULL as INT64), CAST(NULL as STRING);
      
      set startdate = current_datetime() ;
	  set errors = 0	;
      
	  IF length(rtrim(updateproc)) > 0 THEN
        ## Replacing Print With Select as It is Not Supprted in BQ 
        IF trace_flag = 1 THEN
          Select Concat('Update proc found - using ' , UpdateProc );
        END IF;
        
        ## Commenting This Whole Block , This Commented Block is Not Translated into BQ Syntax To Keep Source Logic
		## Looking for alternates As BQ Does not Supports Dynamic Procedure Calls 
		Select "UpdateProc Found , Block Commented" ;
        ##SELECT
        ##    '@TableName VARCHAR(100),@Row_Count BIGINT, @UID_Columns VARCHAR(800),@IsFullLoad BIT' AS __parmdefinition,
        ##    concat(CASE
        ##      WHEN strpos(updateproc, 'EXEC') = 0 THEN 'EXECUTE '
        ##      ELSE ''
        ##    END, updateproc) AS __nsql
        ##;
        ##BEGIN
        ##  CALL sp_executesql(nsql, parmdefinition, maintablename, row_count, uid_columns, isfullload);
        ##EXCEPTION WHEN ERROR THEN
        ##  SELECT
        ##      1 AS __errors,
        ##      concat('Step 3 Failed: UpdateProc load: ', @@error.message) AS __logmessage
        ##  ;
        ##  CALL utility.tolog(maintablename, startdate, logmessage, 'E', CAST(NULL as INT64), nsql);
        ##  IF trace_flag = 1 THEN
        ##    ##PRINT @LogMessage
        ##    ##BigQuery does not support any equivalent for PRINT or LOG.
        ##  END IF;
        ##END;
        
      ELSE
        ##No UPDATEDDATE column - reload whole table then only rename it from stage to main table and back
        
		## Replacing Print With Select as It is Not Supprted in BQ 
		IF trace_flag = 1 THEN
          Select 'Using RENAME for full load' ;
        END IF;
		
        SET step = 'Step 3 Failed: SQL RENAME: ';
        BEGIN
          DECLARE adddeletedarchivedrowssql STRING;
          DECLARE dropstatssql STRING;
          
          ## Replacing tolog with Select to log Data while execution
          Select maintablename, startdate, 'Step 3: RENAME load started', 'I', CAST(NULL as INT64), CAST(NULL as STRING);
          
		  ##1. Pre-screening of row counts in Stage and Main table

          SET step = 'Step 3 Failed: Pre-screening stage table for 0 Inserted rows: ';          
          Execute Immediate  "Select count(1) from @table_name WHERE LND_UpdateType NOT IN ('D','A')" into stagetablerowcount_i using table_name = stagetablename;
          Execute Immediate  "Select count(1) from @table_name WHERE LND_UpdateType IN ('D','A')" into stagetablerowcount_d_a using table_name = stagetablename;
          Execute Immediate  "Select count(1) from @table_name WHERE LND_UpdateType Not IN ('D','A')" into maintablerowcount_i_u using table_name = maintablename;
          Execute Immediate  "Select count(1) from @table_name WHERE LND_UpdateType IN ('D','A')" into maintablerowcount_d_a using table_name = maintablename;
          
		  ## Remove Variable Assignments as it is Directly Done by Execute Immidiate Steps Above 

          SELECT
              concat('1. Stage table ', stagetablename, ' has ', substr(CAST(stagetablerowcount_i as STRING), 1, 30), ' I rows and ', substr(CAST(stagetablerowcount_d_a as STRING), 1, 30), ' D/A rows. Main table ', maintablename, ' has ', substr(CAST(maintablerowcount_i_u as STRING), 1, 30), ' I/U rows and ', substr(CAST(maintablerowcount_d_a as STRING), 1, 30), ' D/A rows.') AS __logmessage
          ;
          
          ## Replacing tolog with Select to log Data while execution
          Select maintablename, startdate, logmessage, 'I', CAST(NULL as INT64), CAST(NULL as STRING);
          
		  IF trace_flag = 1 THEN
            ##BigQuery does not support any equivalent for PRINT or LOG.
          END IF;
          
		  IF stagetablerowcount_i = 0 THEN
            SELECT
                concat('1. DATA LOSS PREVENTION ALERT!! ABORT LANDING DATA TRANSFER: Stage table ', stagetablename, ' has ', substr(CAST(stagetablerowcount_i as STRING), 1, 30), ' I rows and ', substr(CAST(stagetablerowcount_d_a as STRING), 1, 30), ' D/A rows. Main table ', maintablename, ' has ', substr(CAST(maintablerowcount_i_u as STRING), 1, 30), ' I/U rows and ', substr(CAST(maintablerowcount_d_a as STRING), 1, 30), ' D/A rows.') AS __logmessage
            ;
            RAISE USING MESSAGE = '51000, logmessage, 1, ';
          END IF;

          ##2. Copy deleted and archived rows from the main table into stage table before table rename
				##This step need to keep deleted and archived rows we got from CDC - in full load they all will be removed
				##We just insert them all to stage from main table - its the fastest way.
				##If stage table already have D and A rows inserted by the previous run which stopped or failed in the middle,
				##do NOT reinsert D and A rows from the main table again to prevent duplicate rows and ensure restartability of the proc.


          SET adddeletedarchivedrowssql = concat('INSERT INTO ', stagetablename, ' SELECT * FROM ', maintablename, 'WHERE LND_UpdateType IN ("D","A") AND NOT EXISTS (SELECT 1 FROM ', stagetablename, ' WHERE LND_UpdateType IN ("D","A"))');
		  SET query = adddeletedarchivedrowssql;
          ##Commenting LongPrint
          
		  IF trace_flag = 1 THEN
			## Replacing longprint with Select to log Data while execution
			##  CALL utility.longprint(adddeletedarchivedrowssql);
			Select adddeletedarchivedrowssql;
          END IF;
          EXECUTE IMMEDIATE adddeletedarchivedrowssql;
          
		  ## Replacing tolog with Select to log Data while execution
          set logmessage = concat('2. Inserted soft Deleted and Archived rows from ', maintablename, ' into ', stagetablename);
          ##CALL utility.tolog
		  Select maintablename, startdate, logmessage, 'I', -1, substr(CAST(-1 as STRING), 1, 2147483647);
          
		  ##IF trace_flag = 1 THEN
          ##  ##BigQuery does not support any equivalent for PRINT or LOG.
          ##END IF;
          
		  ## Stats Not Required in BQ 
		  Select "Stats Not Required in BQ  This Code Block Dropping and Recreating Stats is Commented"; 
		  /*
		  CALL utility.get_dropstatistics_sql(stagetablename, dropstatssql);
          IF dropstatssql <> '' THEN
            SET query = dropstatssql;
            SET step = 'Step 3 Failed: SQL Drop Stats: ';
            EXECUTE IMMEDIATE dropstatssql;
            SELECT
                concat('3. Dropped Statitics on the stage table ', stagetablename, ' before recreating all Statistics on stage table in the next step and rename it as main table. Saved the day!') AS __logmessage
            ;
            CALL utility.tolog(maintablename, startdate, logmessage, 'I', CAST(NULL as INT64), dropstatssql);
            IF trace_flag = 1 THEN
              ##BigQuery does not support any equivalent for PRINT or LOG.
            END IF;
          ELSE
            SELECT
                concat('3. No Statitics to drop on the stage table ', stagetablename, ' before creating all Statistics on stage table in the next step and rename it as main table') AS __logmessage
            ;
            CALL utility.tolog(maintablename, startdate, logmessage, 'I', CAST(NULL as INT64), dropstatssql);
            IF trace_flag = 1 THEN
              ##BigQuery does not support any equivalent for PRINT or LOG.
            END IF;
          END IF;
		  
          IF statssql <> '' THEN
            SET step = 'Step 3 Failed: SQL Create Stats: ';
            SET query = statssql;
            IF trace_flag = 1 THEN
              CALL utility.longprint(statssql);
            END IF;
            EXECUTE IMMEDIATE statssql;
            SELECT
                concat('4. Created Statitics on the stage table ', stagetablename) AS __logmessage
            ;
            CALL utility.tolog(maintablename, startdate, logmessage, 'I', CAST(NULL as INT64), statssql);
            IF trace_flag = 1 THEN
              ##BigQuery does not support any equivalent for PRINT or LOG.
            END IF;
          ELSE
            SELECT
                concat('4. No Statitics to create on the stage table ', stagetablename, ' based on ', maintablename) AS __logmessage
            ;
            CALL utility.tolog(maintablename, startdate, logmessage, 'I', CAST(NULL as INT64), statssql);
            IF trace_flag = 1 THEN
              ##BigQuery does not support any equivalent for PRINT or LOG.
            END IF;
          END IF;
		  */
		  
		  Begin
		    Begin TRANSACTION;
		  
		  
			  ##5. Table swap
			  SET step = 'Step 3 Failed: SQL Transfer Object: ';
			  SET renamesql = 'NoPrint';
			  
			  ## Replacing Next 2 Block of Table Swap and Create Empty Stage 
			  ## Changing it to 1.Truncate Main , 2.Load to Main from Stage , 3. Truncate Stage 
			  
			  ## CALL LND_TBOS_SUPPORT.get_transferobject_sql(stagetablename, maintablename, renamesql);
			  ## SET query = renamesql;
			  
			  ## New Logic( Table swap and Create Empty Stage ) Step-1
			  set renamesql = concat("Truncate ",maintablename);
			  EXECUTE IMMEDIATE renamesql;
			  
			  ##Commenting as of now 
			  ##IF trace_flag = 1 THEN
			  ##  CALL utility.longprint(renamesql);
			  ##END IF;
			  
			  ## New Logic( Table swap and Create Empty Stage ) Step-2
			  set renamesql = concat('INSERT INTO ', maintablename , ' SELECT * FROM ', stagetablename);
			  EXECUTE IMMEDIATE renamesql;
			  
			  set logmessage = concat('5. Renamed ', stagetablename, ' to ', maintablename) ;
			  
			  ## Replacing ToLog with Select to log details While Execution  
			  ##CALL utility.tolog()
			  select maintablename, startdate, logmessage, 'I', CAST(NULL as INT64), renamesql;
			  
			  ##IF trace_flag = 1 THEN
			  ##  ##BigQuery does not support any equivalent for PRINT or LOG.
			  ##END IF;
			  
			  SET step = 'Step 3 Failed: SQL Create Empty Copy: ';
			  SET nsql = 'NoPrint';
			  ##CALL LND_TBOS_SUPPORT.get_createemptycopy_sql(maintablename, stagetablename, nsql);
			  
			  ## New Logic( Table swap and Create Empty Stage ) Step-3
			  set nsql = concat("Truncate ",stagetablename);
			  
			  SET query = nsql;
			  IF trace_flag = 1 THEN
				##  CALL utility.longprint(nsql);
				select nsql;
			  END IF;
			  EXECUTE IMMEDIATE nsql;
			  set logmessage = concat('6. Created an empty copy of ', maintablename, ' as ', stagetablename) ;
		  EXCEPTION WHEN ERROR THEN
				SELECT @@error.message;
				ROLLBACK TRANSACTION;
		  END;
		   
          ## Replacing ToLog with select in BQ 
          ##CALL utility.tolog()
		  select maintablename, startdate, logmessage, 'I', CAST(NULL as INT64), CAST(NULL as STRING);
          
		  ##IF trace_flag = 1 THEN
          ##  ##BigQuery does not support any equivalent for PRINT or LOG.
          ##END IF;
          
		  SET step = concat('Step 3 Failed: SQL Delete SSISLoadCheck rows for ', maintablename, ': ');
          INSERT INTO LND_TBOS_SUPPORT.SSISLoadCheckLog (loaddate, loadsource, loadstep, loadinfo, row_count, lnd_updatedate)
            SELECT
                ssisloadcheck.loaddate,
                ssisloadcheck.loadsource,
                ssisloadcheck.loadstep,
                ssisloadcheck.loadinfo,
                row_count,
                current_datetime() AS lnd_updatedate
              FROM
                LND_TBOS_SUPPORT.SSISLoadCheck
              WHERE SSISLoadCheck.loadsource = maintablename
          ;
          DELETE FROM LND_TBOS_SUPPORT.SSISLoadCheck WHERE SSISLoadCheck.loadsource = maintablename;
          set logmessage = concat('7. Deleted LND_TBOS_SUPPORT.SSISLoadCheck rows for the next full load of ', maintablename, ' after saving them in LND_TBOS_SUPPORT.SSISLoadCheckLog for future reference'); 
          
          ## Commenting ToLog Replacing it with Select 
          ##CALL utility.tolog()
		  Select maintablename, startdate, logmessage, 'I', CAST(NULL as INT64), CAST(NULL as STRING);
          
		  ##IF trace_flag = 1 THEN
          ##  ##BigQuery does not support any equivalent for PRINT or LOG.
          ##END IF;
          ##CALL utility.tolog()
		  
		  Select maintablename, startdate, 'Step 3: Load afetr SSIS Finished', 'I', CAST(NULL as INT64), CAST(NULL as STRING);
          
		  ##Commenting as of Now Looking for alternate Options
          ##IF length(rtrim(runafterproc)) > 0 THEN
          ##  IF trace_flag = 1 THEN
          ##    ##BigQuery does not support any equivalent for PRINT or LOG.
          ##  END IF;
          ##  SELECT
          ##      '@TableName VARCHAR(100), @UID_Columns VARCHAR(800)' AS __parmdefinition,
          ##      concat(CASE
          ##        WHEN strpos(runafterproc, 'EXEC') = 0 THEN 'EXECUTE '
          ##        ELSE ''
          ##      END, runafterproc) AS __nsql
          ##  ;
          ##  BEGIN
          ##    CALL sp_executesql(nsql, parmdefinition, maintablename, uid_columns);
          ##  EXCEPTION WHEN ERROR THEN
          ##    SELECT
          ##        concat('LandingDataTransferAfterSSIS Failed:', @@error.message) AS __logmessage
          ##    ;
          ##    CALL utility.tolog(maintablename, startdate, logmessage, 'E', CAST(NULL as INT64), nsql);
          ##    IF trace_flag = 1 THEN
          ##      ##BigQuery does not support any equivalent for PRINT or LOG.
          ##    END IF;
          ##  END;
          ##END IF;
        EXCEPTION WHEN ERROR THEN
          Set errors = 1;
		  set logmessage = concat(step, @@error.message); 
			Select logmessage;
        END;
      END IF;
      
	  ##No target-dialect support for source-dialect-specific SET
	  
    END ;
    set indicat = indicat + 1;
    END While ;
    ## Commenting ToLog Replacing it with Select in BQ 
    ## CALL utility.tolog() 
	select 'LND_TBOS_SUPPORT.LandingDataTransferAfterSSIS', logdate, 'Finished', 'I', CAST(NULL as INT64), CAST(NULL as STRING);
  
/*
--===============================================================================================================
-- !!! DEVELOPER TESTING ZONE to thoroughly test the code for various scenarios !!!
--===============================================================================================================


SELECT 
	* --LoadSource, LoadDate, Row_Count
FROM Utility.SSISLoadCheck
WHERE LoadStep = 'S:3' AND Row_Count > 0
ORDER BY LoadDate DESC

SELECT T.FullName, S.LoadSource FROM Utility.TableLoadParameters T
LEFT JOIN Utility.SSISLoadCheck S ON S.LoadSource = T.FullName AND S.LoadStep = 'S:3' AND S.Row_Count > 0
WHERE T.Active = 1 AND S.LoadSource IS NULL
ORDER by TableName


*/

  END;