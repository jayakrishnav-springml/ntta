## Translation time: 2024-03-05T10:34:47.496335Z
## Translation job ID: 86e50ade-b689-41b3-9ba9-6cce7f91106a
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/EDW_TRIPS/SPs/Utility_Row_Count.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE OR REPLACE PROCEDURE EDW_TRIPS_SUPPORT.Row_Count(row_count INT64)

  BEGIN
  /*
USE EDW_TRIPS 
GO
IF OBJECT_ID ('Utility.Row_Count', 'P') IS NOT NULL DROP PROCEDURE Utility.Row_Count
GO

###################################################################################################################
Example:
##################################################################################################################-
DECLARE @Row_Count BIGINT
EXEC Utility.Row_Count @Row_Count OUTPUT 

===================================================================================================================
Proc Description: 
##################################################################################################################-
This proc is calculating row counts on the last query run on this scope. Uses mostly for logging
@Row_Count - Variable to return the number of rows processed
===================================================================================================================
Change Log:
##################################################################################################################-
CHG0037837 Andy	01/10/2020	New!
          Egen  12/03/2024 This Procedure is Using Sys Schema Tables  Replacing Logic to Get Similar info from BQ Metadata Tables 
###################################################################################################################
*/
  

    /*
	@@ROWCOUNT workaround
	To work around lack of support for @@ROWCOUNT, create a stored procedure that will retrieve the last row count from sys.dm_pdw_request_steps and then EXEC Utility.Row_Count after a DML statement.
	*/

  WITH
    ## Getting Current Sessions ID using @@session_id 

    ## Getting Latest JOB ID 
    lastrequest AS (
      select job_id from `region-us-south1`.INFORMATION_SCHEMA.JOBS  
      where session_info.session_id in ( SELECT concat(@@session_id ,"=") ) ## Adding "=" to @@session_id to match session_id Pattern 
      order by creation_time desc 
      limit 1
    ),

    ## Getting Stage by row_count for Most Recent Job ID 
    lastrequestrowcounts as (
    select job_id , js.ID as  step_index , js.records_read , js.records_written  as row_count
    from   `region-us-south1`.INFORMATION_SCHEMA.JOBS  j join unnest(job_stages) js
    where job_id in (select job_id from lastrequest )  and js.records_written > 0
    order by 2 desc 
     limit 1
    )



    SELECT
        lastrequestrowcounts.row_count AS __row_count
      FROM
        lastrequestrowcounts;

    ## For Testing , Added By EGEn
    ## Enable Sessions 1st and then Run Below Script 
    /* 
      DECLARE row_count INT64 DEFAULT NULL;
      Create temp table words  ( Word String) 
      insert into words
      select "Hi"
      union all 
      select "Hello"
      union all 
      select "World";
    
      CALL EDW_TRIPS_Utility.Row_Count`(row_count);
    */

  END;
