CREATE OR REPLACE PROCEDURE EDW_TRIPS_SUPPORT.ToLog(logsource STRING, procstartdate DATETIME, logmessage STRING, logtype STRING, row_count INT64, query STRING)
BEGIN
/*
#####################################################################################################
Proc Description: This PROCEDURE uses Information Schema Jobs View to get the Info related 	to the jobs and loads the stats to EDW_TRIPS_SUPPORT.ProcessLog Table for future references 
	Input:
		logsource 		: Log Source , Mainly Stored Procedure name 
		procstartdate	: Stored Procedure execution start Date Time 
		logmessage 		: Message to Log 
		logtype				: Message Type ( I , E etc...)
		row_count(Optional)	: Rows Modified/inserted by last script 
		query(Optional) 	: Last executed Script 
---------------------------------------------------------------------------------------------
============================================================================================
Change Log:
--------------------------------------------------------------------------------------------
********    EGen        16-05-2024     New -- Taking REFERENCES from Utility.ToLog 
=============================================================================================
Example:   
---------------------------------------------------------------------------------------------
CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, log_message, 'I', -1, NULL);
CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, log_message, 'I', NULL, NULL);

#######################################################################################
*/


	DECLARE logdate DateTime DEFAULT Current_DateTime('America/Chicago');
	Declare querysubmitdate DATETIME;
	Declare queryenddate DATETIME;
	Declare ProcTime String;
	Declare QueryTime String ;
	Declare ProcTimeInSec Numeric(31,3);
	Declare QueryTimeInSec Numeric(31,3);
	DECLARE query_id  String ;
	Declare Session_ID String DEFAULT @@session_id;
	Declare command String ;
	Declare error_id String DEFAULT Null ;
	Declare query_row_count int64;
	Declare status String;
	Declare Trace_Flag int64 default 0; ## Testing
	
	## Added in BQ 
	DECLARE LogStartDate Timestamp DEFAULT Current_Timestamp();
	Declare CurrentJobId String default @@current_job_id;
	Declare This_procstartdate Datetime default procstartdate;

	set query_row_count = row_count;

	IF (row_count = -1 OR logmessage = '-1' OR query = '-1')
	Then
		## :: Get the last query executed in this session after proc start time which has row count 
		CREATE OR REPLACE TEMPORARY TABLE _SESSION.CTE_Requests AS 
		(   Select job_id from region-us-south1.INFORMATION_SCHEMA.JOBS 
			where parent_job_id in ( select parent_job_id from region-us-south1.INFORMATION_SCHEMA.JOBS where job_id = CurrentJobId)
			and ( dml_statistics is not null   -- to Pick Up DML 
				or lower(query) like '%create%replace%table%'  -- to Pick Up DDL
				)
			and end_time < LogStartDate
		);

		CREATE OR REPLACE TEMPORARY TABLE _SESSION.CTE_lastrequestrowcounts AS 
		( select job_id,j.query,j.start_time  , j.end_time, js.ID as  step_index ,
		js.status,
		Coalesce ( j.dml_statistics.inserted_row_count,j.dml_statistics.updated_row_count ,j.dml_statistics.deleted_row_count , js.records_written ,js.records_read  ) as Row_count,  js.records_read , js.records_written
		from   region-us-south1.INFORMATION_SCHEMA.JOBS  j 
			join unnest(job_stages) js
			where job_id in ( Select job_id from  CTE_Requests )  
			order by 4 desc ,js.ID desc
			limit 1
		);
		
		set (query_id , query , query_row_count ,querysubmitdate , queryenddate)  = (SELECT AS STRUCT job_id ,query , Row_count  , DATETIME(start_time ,'America/Chicago'), DATETIME(end_time,'America/Chicago') from _SESSION.CTE_lastrequestrowcounts);
		
		## :: @QueryID was already logged in the current proc execution from an earlier query. This is no good! Clean it up!

		IF EXISTS ( SELECT  1 FROM EDW_TRIPS_SUPPORT.ProcessLog WHERE ProcessLog.logdate >= This_procstartdate AND ProcessLog.sessionid = Session_ID AND ProcessLog.queryid = query_id ) 
		THEN
			SET (query_id, querysubmitdate, queryenddate, command, error_id, query_row_count, status) = ( SELECT as STRUCT CAST(NULL AS STRING) AS queryid,
										  CAST(NULL AS DATETIME) AS querysubmitdate,
										  CAST(NULL AS DATETIME) AS queryenddate,
										  CAST(NULL AS STRING) AS command,
										  CAST(NULL AS STRING) AS error_id,
										  CAST(NULL AS INT64) AS query_row_count,
										  CAST(NULL AS STRING) AS status 
						);
		END IF;

		SET status = coalesce(status, 'Completed');
		SET logmessage = coalesce(nullif(nullif(logmessage, '-1'), ''), status);




		
		/*

		SELECT	@QueryTime		= CASE WHEN @querysubmitdate IS NOT NULL THEN Utility.uf_Find_Elapsed_Time(@querysubmitdate,@logdate) END;
        
        */
				
        ## Commenting DateDiff on MILLISECONDs         
        set QueryTimeInSec = cast((SELECT CASE WHEN querysubmitdate IS NOT NULL 
											THEN 
												/*
												CASE WHEN DATETIME_DIFF(logdate,querysubmitdate,HOUR) >= 596 
													THEN 
												*/
												DATETIME_DIFF(logdate,querysubmitdate,SECOND) 
												/*
												ELSE DATETIME_DIFF(logdate,querysubmitdate,MILLISECOND)/1000.0 
												END
												*/
									END as QueryTimeInSec) as Numeric);

		

	END IF;
	
	/*
	SELECT	@ProcTime		= Utility.uf_Find_Elapsed_Time(@procstartdate,@logdate);
    */
	## Commenting DateDiff on MILLISECONDs  
	set ProcTimeInSec	= cast(/*(SELECT CASE WHEN DATETIME_DIFF(logdate,procstartdate,HOUR) >= 596 
													THEN */ 
													DATETIME_DIFF(logdate,procstartdate,SECOND) 
												/*
												ELSE DATETIME_DIFF(logdate,procstartdate,MILLISECOND)/1000.0 
												
											END as ProcTimeInSec) */ 
											as Numeric);
											-- DATEDIFF(MILLISECOND, @procstartdate,@logdate)/1000.0 -- Was not enough...
											-- FYI. For millisecond, the maximum difference between startdate and enddate is 24 days, 20 hours, 31 minutes and 23.647 seconds. 
											-- FYI. For second, the maximum difference is 68 years, 19 days, 3 hours, 14 minutes and 7 seconds.

	
	
	SET logtype = CASE WHEN error_id IS NOT NULL THEN 'E' WHEN logtype IN ('I','W','E') THEN logtype ELSE 'I' END;
	
	## Loading Data in ProcessLog Table Will Update this in End 
	INSERT INTO EDW_TRIPS_SUPPORT.ProcessLog -- Utility.ProcessLog
	(
				logdate,  -- CURRENT_DATE 
				logsource,  -- Input 
				LogMessage,  -- Input 
				LogType,    -- Input 
				Row_Count,   -- Info From JOBS  
				ProcTime,    -- Time Between Proc Start Time to Log Start Time 
				QueryTime,   -- IF Query Submit time present then Time between that to CURRENT_TIMESTAMP
				ProcTimeInSec, -- Same as ProcTime
				QueryTimeInSec,  -- same as QueryTime
				procstartdate,   -- Input 
				querysubmitdate,  --  Info From Jobs 
				QueryEndDate,     -- Info From Jobs 
				SessionID,       -- @@Sessiosn_ID 
				QueryID,		-- Info From Jobs 
				Query			 --Info From Jobs 
			)
	VALUES(
				logdate, 
				logsource, 
				logmessage,
				logtype,
				query_row_count,
				Null, -- Setting Null for Now Since this is a String type Field calculated using utility Func
				Null, -- Setting Null For Now Since this is a String type Field calculated using utility Func 
				ProcTimeInSec,-- Setting Null for Now , need to Calculate ##resolved 2024-05-17
				QueryTimeInSec, -- Setting Null for Now , need to Calculate ##resolved 2024-05-17
				procstartdate,
				querysubmitdate,
				queryenddate,
				Session_ID,
				query_id,
				query
			);


END;