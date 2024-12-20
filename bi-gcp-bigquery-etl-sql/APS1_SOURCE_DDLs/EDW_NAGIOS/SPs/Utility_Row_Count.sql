CREATE PROC [Utility].[Row_Count] @Row_Count [BIGINT] OUT AS 
/*
USE EDW_NAGIOS 
GO
IF OBJECT_ID ('Utility.Row_Count', 'P') IS NOT NULL DROP PROCEDURE Utility.Row_Count
GO

###################################################################################################################
Example:
-------------------------------------------------------------------------------------------------------------------
DECLARE @Row_Count BIGINT
EXEC Utility.Row_Count @Row_Count OUTPUT 

===================================================================================================================
Proc Description: 
-------------------------------------------------------------------------------------------------------------------
This proc is calculating row counts on the last query run on this scope. Uses mostly for logging

@Row_Count - Variable to return the number of rows processed

===================================================================================================================
Change Log:
-------------------------------------------------------------------------------------------------------------------
CHG0037837 Andy	01/10/2020	New!
###################################################################################################################
*/
BEGIN
	
	/*
	@@ROWCOUNT workaround
	To work around lack of support for @@ROWCOUNT, create a stored procedure that will retrieve the last row count from sys.dm_pdw_request_steps and then EXEC Utility.Row_Count after a DML statement.
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
	SELECT TOP 1 @Row_Count = row_count FROM LastRequestRowCounts ORDER BY step_index DESC
END
