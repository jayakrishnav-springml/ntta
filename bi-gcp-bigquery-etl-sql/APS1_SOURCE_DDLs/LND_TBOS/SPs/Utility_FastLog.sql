CREATE PROC [Utility].[FastLog] @Source [VARCHAR](200),@Log_Message [VARCHAR](8000),@Row_Count [BIGINT] AS --																							-- @Row_Count = -3 means it's an error

/*
USE LND_TBOS
GO
IF OBJECT_ID ('Utility.FastLog', 'P') IS NOT NULL DROP PROCEDURE Utility.FastLog
GO
###################################################################################################################
Example:
-------------------------------------------------------------------------------------------------------------------
EXEC Utility.FastLog 'dbo.Dim_Customer', 'Load failed', -3

===================================================================================================================
Proc Description: 
-------------------------------------------------------------------------------------------------------------------
This proc make automated process of logging (enstead of using ToLog). Less amount of parameters, data takes from System tables.


@Source - Source that is logging - name of the stored proc or table (for SSIS)
@Log_Message - Message to log, if = '-1' - takes it from query label and status of the query (Completed,Failed...)
@Row_Count - Row count to log. If = -1 - proc take it from sys.dm_pdw_request_steps. If = -3 - proc thinks it's an error type message (for those situations error was not sent)
===================================================================================================================
Change Log:
-------------------------------------------------------------------------------------------------------------------
CHG0037837			Andy	01/10/2020	New!
###################################################################################################################

*/

BEGIN 
	/*====================================== TESTING =======================================================================*/
	--DECLARE @Source VARCHAR(200) = 'dbo.Dim_Customer', @Log_Message VARCHAR(8000)  = 'Log started', @Row_Count BIGINT = NULL
	/*====================================== TESTING =======================================================================*/

	DECLARE @log_date DATETIME2(3) = SYSDATETIME(), @QueryElapsedTime VARCHAR(50), @ProcElapsedTime VARCHAR(50), @Log_SQL VARCHAR(MAX), @log_type VARCHAR(1) = 'I', @command VARCHAR(4000) -- Default value
	DECLARE @request_id VARCHAR(36), @error_id VARCHAR(36), @error_Detail VARCHAR(4000), @QueryStart DATETIME2(3), @ProcStart DATETIME2(3), @end_time DATETIME2(3), @status VARCHAR(32), @label VARCHAR(255)
	DECLARE @QueryID VARCHAR(12), @session_id VARCHAR(12) = SESSION_ID(), @resource_class VARCHAR(20), @ProcTimeInSec DECIMAL(19,3), @QueryTimeInSec DECIMAL(19,3), @Trace_Flag BIT = 0 -- Testing

	DECLARE @Log_TraceDate DATETIME2(3)

	-- Getting the name of the proc was running this log. If it has table name inside - will get it, if not - get the first not utility one
	SELECT TOP 1
		@command = REPLACE(command,'EXEC ',''),
		@ProcStart = start_time
	FROM
	(
		SELECT TOP 1
			command,
			start_time,
			1 AS Ord
		FROM sys.dm_pdw_exec_requests
		WHERE session_id = @session_id
		AND status = 'Running'
		AND command LIKE 'EXEC %' + @Source + '%'  
		ORDER BY start_time ASC
		--UNION ALL
		--SELECT TOP 1
		--	command,
		--	start_time,
		--	2 AS Ord
		--FROM sys.dm_pdw_exec_requests
		--WHERE session_id = SESSION_ID()
		--AND status = 'Running'
		--AND command LIKE 'EXEC %' AND command NOT LIKE 'EXEC%Utility.%'  
		--ORDER BY start_time ASC
		UNION ALL
		SELECT TOP 1
			command,
			start_time,
			3 AS Ord
		FROM sys.dm_pdw_exec_requests
		WHERE session_id = SESSION_ID()
		AND status = 'Running'
		ORDER BY start_time ASC
	) AS InnerQ
	ORDER BY Ord

	IF @Trace_Flag = 1 
	BEGIN
		SET @Log_TraceDate = SYSDATETIME()
		PRINT 'FastLog Running time (Get ProcStart step) ' + Utility.uf_Find_Elapsed_Time(@log_date,@Log_TraceDate) 
	END

	SELECT TOP 1
		@request_id = r.[request_id],
		@resource_class = r.resource_class,
		@error_id = r.error_id,
		@Log_SQL = r.[command],
		@QueryStart = r.submit_time,
		@end_time = r.[end_time],
		@status = r.[status],
		@label = r.[label]
	FROM sys.dm_pdw_exec_requests r 
	WHERE r.session_id = @session_id AND r.[start_time] >= @ProcStart AND r.resource_class IS NOT NULL
	ORDER BY r.end_time DESC;

	IF @Trace_Flag = 1 
	BEGIN
		SET @Log_TraceDate = SYSDATETIME()
		PRINT 'FastLog Running time (Get Status step) ' + Utility.uf_Find_Elapsed_Time(@log_date,@Log_TraceDate) 
	END

	SET	@status = ISNULL(@status,'Completed')
	SET	@log_message = ISNULL(NULLIF(NULLIF(@log_message,'-1'),''), @status + ': ' + @label)
	SET	@log_type = CASE 
						WHEN @Row_Count = -3 THEN 'E' 
						WHEN CHARINDEX('!',@Log_Message) > 0 THEN 'W'
						WHEN @status = 'Failed' THEN 'E'
						WHEN @status = 'Cancelled' THEN 'W'
						WHEN @error_id IS NOT NULL THEN 'E'
						ELSE 'I'
					END
	SET @Row_Count = NULLIF(@Row_Count,-3)

	IF @error_id IS NOT NULL
	BEGIN
		SELECT  TOP 1 @error_Detail = e.details
		FROM    sys.dm_pdw_errors e
		WHERE   e.error_id = @error_id

		IF @Trace_Flag = 1 
		BEGIN
			SET @Log_TraceDate = SYSDATETIME()
			PRINT 'FastLog Running time (Get Error step) ' + Utility.uf_Find_Elapsed_Time(@log_date,@Log_TraceDate) 
		END
	END


	IF @Row_Count = -1 -- if @Row_Count = -1  - it is a request to get row_count
	BEGIN
		IF @request_id IS NOT NULL 
		BEGIN
			SELECT  TOP 1 @row_count = row_count
			FROM    sys.dm_pdw_request_steps
			WHERE   row_count >= 0 AND request_id = @request_id
			ORDER BY step_index DESC
		END
		ELSE SET @row_count = NULL

		IF @Trace_Flag = 1 
		BEGIN
			SET @Log_TraceDate = SYSDATETIME()
			PRINT 'FastLog Running time (Get Row_Count step) ' + Utility.uf_Find_Elapsed_Time(@log_date,@Log_TraceDate) 
		END
	END

	IF @Row_Count IS NULL
		SET	@Log_SQL = @command
	ELSE
		SET	@Log_SQL = ISNULL(@Log_SQL, @command)



	SET	@QueryStart = ISNULL(@QueryStart,@ProcStart)
	SET	@end_time = ISNULL(@end_time, @Log_Date)

	IF @error_Detail IS NOT NULL -- if @error_Detail IS NOT NULL  - we should add this infor to Log message
	BEGIN
		SET @Log_Message = @Log_Message + ': ' + @status + ' || Detail: ' + @error_Detail
	END

	--:: @QueryID was already logged in the current proc execution from an earlier query. This is no good! Clean it up!
	IF	EXISTS (SELECT 1 FROM Utility.ProcessLog WHERE LogDate >= @ProcStart AND SessionID = @session_id AND QueryID = @request_id) 
		SELECT @request_id = NULL, @QueryStart = NULL, @end_time = NULL, @Log_SQL = NULL, @Row_Count = NULL, @resource_class = NULL

	SET @QueryElapsedTime = Utility.uf_Find_Elapsed_Time(@QueryStart,@end_time)
	SET @ProcElapsedTime = Utility.uf_Find_Elapsed_Time(@ProcStart,@Log_Date)
	SET @QueryTimeInSec = CASE WHEN @QueryStart IS NOT NULL THEN DATEDIFF(MILLISECOND, @QueryStart,@end_time)/1000.0 END
	SET @ProcTimeInSec	= DATEDIFF(MILLISECOND, @ProcStart,@Log_Date)/1000.0 -- FYI. For millisecond, the maximum difference between startdate and enddate is 24 days, 20 hours, 31 minutes and 23.647 seconds. 

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
				@Log_Date, 
				@Source, 
				@Log_Message,
				@Log_Type,
				@Row_Count,
				@ProcElapsedTime,
				@QueryElapsedTime,
				@ProcTimeInSec,
				@QueryTimeInSec,
				@ProcStart,
				@QueryStart,
				@end_time,
				@session_id,
				@request_id,
				@Log_SQL,
				@resource_class
			)

	IF @Trace_Flag = 1 
	BEGIN
		SET @Log_TraceDate = SYSDATETIME()
		PRINT 'FastLog Running time (Finish) ' + Utility.uf_Find_Elapsed_Time(@log_date,@Log_TraceDate) 
	END


END



