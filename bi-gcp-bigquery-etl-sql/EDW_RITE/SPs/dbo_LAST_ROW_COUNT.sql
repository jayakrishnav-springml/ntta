CREATE PROC [dbo].[LAST_ROW_COUNT] @ROW_COUNT [BIGINT] OUT AS

BEGIN
	/*
	@@ROWCOUNT workaround
	To work around lack of support for @@ROWCOUNT, create a stored procedure that will retrieve the last row count from sys.dm_pdw_request_steps and then execute EXEC LastRowCount after a DML statement.
	*/
	WITH LastRequest as 
	(   SELECT TOP 1    request_id
		FROM            sys.dm_pdw_exec_requests
		WHERE           session_id = SESSION_ID()
		AND             resource_class IS NOT NULL
		ORDER BY end_time DESC
	),
	LastRequestRowCounts as
	(
		SELECT  step_index, row_count
		FROM    sys.dm_pdw_request_steps
		WHERE   row_count >= 0
		AND     request_id IN (SELECT request_id from LastRequest)
	)
	SELECT TOP 1 @ROW_COUNT = row_count FROM LastRequestRowCounts ORDER BY step_index DESC
END
