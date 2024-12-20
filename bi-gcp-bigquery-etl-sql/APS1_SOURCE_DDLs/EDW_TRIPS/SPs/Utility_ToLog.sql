CREATE PROC [Utility].[ToLog] @LogSource [VARCHAR](100),@ProcStartDate [DATETIME2](3),@LogMessage [VARCHAR](4000),@LogType [VARCHAR](1),@Row_Count [BIGINT],@Query [VARCHAR](MAX) AS
/*
IF OBJECT_ID ('Utility.ToLog', 'P') IS NOT NULL DROP PROCEDURE Utility.ToLog

###################################################################################################################
Purpose: Log ETL process execution details in Utility.ProcessLog table. 
-------------------------------------------------------------------------------------------------------------------
Change Log:
-------------------------------------------------------------------------------------------------------------------
CHG0037837	Andy and Shankar		2020-08-20	New!
CHG0038039	Andy and Shankar		2021-01-21	Enhanced to accept @LogMessage = '-1'
CHG0038754	Shankar					2021-04-27	Set @Trace_Flag = 0

-------------------------------------------------------------------------------------------------------------------
Example:
-------------------------------------------------------------------------------------------------------------------
EXEC Utility.ToLog 'dbo.Dim_CollectionStatus_Load_Full', '2020-08-20 10:46:29.193', 'Started full load', 'I', NULL, NULL
SELECT TOP 100 * FROM Utility.ProcessLog ORDER BY 1 DESC
###################################################################################################################
*/

BEGIN

	DECLARE @LogDate DATETIME2(3) = SYSDATETIME(), @QuerySubmitDate DATETIME2(3), @QueryEndDate DATETIME2(3), @ProcTime VARCHAR(50), @QueryTime VARCHAR(50), @ProcTimeInSec DECIMAL(19,3), @QueryTimeInSec DECIMAL(19,3)
	DECLARE @QueryID VARCHAR(12), @SessionID VARCHAR(12), @command VARCHAR(4000), @error_id VARCHAR(36), @query_row_count BIGINT, @ResourceClass VARCHAR(20), @status VARCHAR(32), @label VARCHAR(255), @Trace_Flag BIT = 0 -- Testing

	IF (@Row_Count = -1 OR @LogMessage = '-1' OR @Query = '-1')
	BEGIN
		--:: Get the last query executed in this session after proc start time which has row count and resource class assigned
		WITH CTE_LastRequest AS 
		(   
			SELECT	TOP 1 session_id, request_id, submit_time, end_time, command, error_id, resource_class,[status], [label]
			FROM	sys.dm_pdw_exec_requests
			WHERE	session_id = SESSION_ID() AND start_time >= @ProcStartDate AND resource_class IS NOT NULL 
			ORDER BY end_time DESC, submit_time DESC
		)
		SELECT	TOP 1 
			@SessionID = lr.session_id, 
			@QueryID = lr.request_id, 
			@QuerySubmitDate = lr.submit_time, 
			@QueryEndDate = lr.end_time, 
			@command = lr.command, 
			@error_id = lr.error_id, 
			@ResourceClass = lr.resource_class, 
			@query_row_count = CASE WHEN @Row_Count = -1 OR @Query = '-1' THEN rc.Row_Count ELSE @Row_Count END, 
			@status = lr.[status],
			@label = lr.[label]
		FROM	CTE_LastRequest lr
		JOIN	sys.dm_pdw_request_steps rc ON lr.request_id = rc.request_id
		WHERE	rc.row_count > 0
		ORDER BY rc.step_index DESC

		--:: @QueryID was already logged in the current proc execution from an earlier query. This is no good! Clean it up!
		IF	EXISTS (SELECT 1 FROM Utility.ProcessLog WHERE LogDate >= @ProcStartDate AND SessionID = @SessionID AND QueryID = @QueryID) 
			SELECT @QueryID = NULL, @QuerySubmitDate = NULL, @QueryEndDate = NULL, @command = NULL, @error_id = NULL, @ResourceClass = NULL, @query_row_count = NULL, @label = NULL, @status = NULL

		SET	@status = ISNULL(@status,'Completed')
		SET	@label = ISNULL(NULLIF(@label,''),'Command from ' + @LogSource)
		SET	@LogMessage = ISNULL(NULLIF(NULLIF(@LogMessage,'-1'),''), @status + ': ' + @label)

		IF @Trace_Flag = 1 
		BEGIN
			DECLARE @ToLog_Date1 DATETIME2(3) = SYSDATETIME()
			PRINT @LogMessage + ' @1 Running time ' + Utility.uf_Find_Elapsed_Time(@LogDate,@ToLog_Date1) + ', Query time ' + Utility.uf_Find_Elapsed_Time(@LogDate,@ToLog_Date1)
		END

		SELECT	@Row_Count		= @query_row_count, 
				@Query = ISNULL(NULLIF(NULLIF(@Query,'-1'),''), @command),
				@QueryTime		= CASE WHEN @QuerySubmitDate IS NOT NULL THEN Utility.uf_Find_Elapsed_Time(@QuerySubmitDate,@LogDate) END,
				@QueryTimeInSec = CASE WHEN @QuerySubmitDate IS NOT NULL THEN 
											CASE WHEN DATEDIFF(HOUR, @QuerySubmitDate,@LogDate) >= 596 
													THEN DATEDIFF(SECOND, @QuerySubmitDate,@LogDate) 
													ELSE DATEDIFF(MILLISECOND, @QuerySubmitDate,@LogDate)/1000.0 
											END
									END

		IF @Trace_Flag = 1 
		BEGIN
			DECLARE @ToLog_Date2 DATETIME2(3) = SYSDATETIME()
			PRINT @LogMessage + ' @2 Running time ' + Utility.uf_Find_Elapsed_Time(@LogDate,@ToLog_Date2) + ', Query time ' + Utility.uf_Find_Elapsed_Time(@ToLog_Date1,@ToLog_Date2)
		END

	END	
	
	IF @Trace_Flag = 1 
		DECLARE @ToLog_Date0 DATETIME2(3) = SYSDATETIME()

	SELECT	@ProcTime		= Utility.uf_Find_Elapsed_Time(@ProcStartDate,@LogDate),
			@ProcTimeInSec	= CASE WHEN DATEDIFF(HOUR, @ProcStartDate,@LogDate) >= 596 
													THEN DATEDIFF(SECOND, @ProcStartDate,@LogDate) 
													ELSE DATEDIFF(MILLISECOND, @ProcStartDate,@LogDate)/1000.0 
											END
											-- DATEDIFF(MILLISECOND, @ProcStartDate,@LogDate)/1000.0 -- Was not enough...
											-- FYI. For millisecond, the maximum difference between startdate and enddate is 24 days, 20 hours, 31 minutes and 23.647 seconds. 
											-- FYI. For second, the maximum difference is 68 years, 19 days, 3 hours, 14 minutes and 7 seconds.

	SET @LogType = CASE WHEN @error_id IS NOT NULL THEN 'E' WHEN @LogType IN ('I','W','E') THEN @LogType ELSE 'I' END

	INSERT INTO Utility.ProcessLog
			(
				LogDate, 
				LogSource, 
				LogMessage,
				LogType,
				Row_Count,
				ProcTime,
				QueryTime,
				ProcTimeInSec,
				QueryTimeInSec,
				ProcStartDate,
				QuerySubmitDate,
				QueryEndDate,
				SessionID,
				QueryID,
				Query,
				ResourceClass
			)
	VALUES  (
				@LogDate, 
				@LogSource, 
				@LogMessage,
				@LogType,
				@Row_Count,
				@ProcTime,
				@QueryTime,
				@ProcTimeInSec,
				@QueryTimeInSec,
				@ProcStartDate,
				@QuerySubmitDate,
				@QueryEndDate,
				@SessionID,
				@QueryID,
				@Query,
				@ResourceClass
			)

	IF @Trace_Flag = 1 
	BEGIN
		DECLARE @ToLog_Date3 DATETIME2(3) = SYSDATETIME()
		PRINT @LogMessage + ' @3 Running time ' + Utility.uf_Find_Elapsed_Time(@LogDate,@ToLog_Date3) + ', Query time ' + Utility.uf_Find_Elapsed_Time(@ToLog_Date0,@ToLog_Date3)
	END

END

/*
--===============================================================================================================
-- !!! DEVELOPER TESTING ZONE to thoroughly test the code for various scenarios !!!
--===============================================================================================================

EXEC Utility.ToLog 'dbo.Dim_CollectionStatus_Load_Full', '2020-08-20 10:46:29.193', 'Started full load', NULL, NULL, 'I' -- Info
SELECT TOP 100 * FROM Utility.ProcessLog ORDER BY 1 DESC

EXEC Utility.ToLog 'dbo.Dim_CollectionStatus_Load_Full', '2020-08-20 10:46:29.193', 'Some error message from the CATCH block', NULL, NULL, 'E' -- Error!
SELECT TOP 100 * FROM Utility.ProcessLog ORDER BY 1 DESC

--:: Sample query to test logging Query SQL and Row Count
IF OBJECT_ID('New.Dim_CollectionStatus') IS NOT NULL DROP TABLE New.Dim_CollectionStatus
CREATE TABLE New.Dim_CollectionStatus WITH (CLUSTERED INDEX (CollectionStatusID), DISTRIBUTION = REPLICATE) AS
SELECT LOOKUPTYPECODEID AS CollectionStatusID, LOOKUPTYPECODE AS CollectionStatusCode, LOOKUPTYPECODEDESC AS CollectionStatusDesc
FROM   LND_TBOS.TollPlus.REF_LOOKUPTYPECODES_HIERARCHY 
WHERE  PARENT_LOOKUPTYPECODEID = 3647 -- CollectionStatus
OPTION (LABEL = 'New.Dim_CollectionStatus Load');

EXEC Utility.ToLog 'dbo.Dim_CollectionStatus_Load_Full', '2020-08-20 10:46:29.193', 'Loaded dbo.Dim_CollectionStatus', NULL, -1, 'I' -- Get Row Count for me.
SELECT TOP 100 * FROM Utility.ProcessLog ORDER BY 1 DESC

EXEC Utility.ToLog 'dbo.Dim_CollectionStatus_Load_Full', '2020-08-20 10:46:29.193', 'Loaded dbo.Dim_CollectionStatus', '-1', -1, 'I' -- Now I want to log this Query too! 
SELECT TOP 100 * FROM Utility.ProcessLog ORDER BY 1 DESC


--===============================================================================================================
-- !!! USEFUL DATA VALIDATION SCRIPTS for post prod move monitoring or for others to not reinvent the wheel !!! 
--===============================================================================================================

SELECT * FROM sys.dm_pdw_exec_requests WHERE session_id = 'SID1336444' AND start_time > '2020-08-19 19:41:13.661' ORDER BY submit_time desc
SELECT * FROM sys.dm_pdw_request_steps WHERE request_id IN (SELECT request_id FROM sys.dm_pdw_exec_requests WHERE session_id = 'SID1336444' AND start_time > '2020-08-19 19:41:13.661') AND row_count > 0 ORDER BY step_index DESC
SELECT * FROM sys.dm_pdw_exec_requests WHERE session_id = 'SID1336444' AND resource_class IS NOT null ORDER BY submit_time desc

SELECT * FROM sys.dm_pdw_exec_requests WHERE request_id = 'QID8417726'
SELECT * FROM sys.dm_pdw_request_steps WHERE request_id = 'QID8417726'

SELECT *, DATEDIFF(MILLISECOND,start_time,end_time) QueryTime, DATEDIFF(MILLISECOND,submit_time,end_time) QueryTotalTime FROM sys.dm_pdw_exec_requests WHERE request_id = 'QID8390315'
SELECT DATEDIFF(SECOND,R.submit_time, r.start_time) diff, COUNT(1) RC
FROM sys.dm_pdw_exec_requests r 
WHERE r.resource_class IS NOT NULL
GROUP BY DATEDIFF(SECOND,R.submit_time, r.start_time)
ORDER BY diff DESC, 2 DESC;

*/


