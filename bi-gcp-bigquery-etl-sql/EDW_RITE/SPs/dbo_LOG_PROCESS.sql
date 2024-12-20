CREATE PROC [dbo].[LOG_PROCESS] @SOURCE [VARCHAR](50),@START_DATE [DATETIME],@LOG_MESSAGE [VARCHAR](8000),@ROW_COUNT [BIGINT] AS
 

/*
############################################################################# 
Procedure Name 	: LOG_PROCESS                          
Procedure Desc	: This helper proc logs trace messages from ETL procs
Author			: Shankar
-----------------------------------------------------------------------------
Log:
-----------------------------------------------------------------------------

############################################################################# 
*/


SET NOCOUNT ON

DECLARE @LOG_DATE DATETIME, @ELAPSED_TIME VARCHAR(25) 
SET @LOG_DATE = GETDATE()
SET @ELAPSED_TIME = SUBSTRING(dbo.UF_FIND_ELAPSED_TIME(@START_DATE,@LOG_DATE),1,25)

INSERT INTO dbo.PROCESS_LOG 
        (
            LOG_DATE, 
            ELAPSED_TIME, 
            LOG_SOURCE, 
            LOG_MESSAGE, 
            ROWS_AFFECTED
        )
VALUES  (
            @LOG_DATE, 
            @ELAPSED_TIME, 
            @SOURCE,
			@LOG_MESSAGE,
            @ROW_COUNT
        )


