CREATE PROC [Utility].[FromLog] @Source [VARCHAR](200),@LogFrom [Varchar](23) AS  

/*
USE LND_TBOS
GO
IF OBJECT_ID ('Utility.FromLog', 'P') IS NOT NULL DROP PROCEDURE Utility.FromLog
GO
###################################################################################################################
Example:
-------------------------------------------------------------------------------------------------------------------
EXEC Utility.FromLog 'dbo.Dim_Customer', 2
EXEC Utility.FromLog 'dbo.Dim_Customer', '2020-08-03 03:51:12.879'
EXEC Utility.FromLog 'dbo.Dim_Customer', 20200803

DECLARE @Log_Date DATETIME2(3) = CONVERT(DATETIME2(3), '2020-08-03 03:51:12.879', 121)
EXEC Utility.FromLog 'dbo.Dim_Customer', @Log_Date

===================================================================================================================
Proc Description: 
-------------------------------------------------------------------------------------------------------------------
This proc returning query result from table Utility.ProcessLog. Always ordered by Date DESC (last Log comes first)

@Source - Text to filter result by LogSource value. It's using LIKE '%' + @Source + '%' to filter it.
@LogFrom - Param to filter by date. 
	Can be:
		number (int) - days back from today (beginning of the day - 0 means today)
		Day ID (int) - exact day ID to start from till now
		Date - Date to start from till now
		String (Date in format YYYY-MM-DD hh:mm:ss.mls) - Date to start from till now
		NULL - No Filter

===================================================================================================================
Change Log:
-------------------------------------------------------------------------------------------------------------------
CHG0037837			Andy	01/10/2020	New!
###################################################################################################################

*/

BEGIN	
	/*====================================== TESTING =======================================================================*/
	--DECLARE @Source VARCHAR(200) = '', @StartDate DATETIME2(3)  = '2020-08-02 03:20:33.268', @DaysBack INT = NULL
	/*====================================== TESTING =======================================================================*/

	DECLARE @Log_Date DATETIME2(3) = SYSDATETIME()
	
	SELECT @Log_Date = CASE 
							WHEN @LogFrom IS NULL THEN '2000-01-01' 
							WHEN ISDATE(@LogFrom) = 1 THEN CONVERT(DATETIME2(3), @LogFrom, 121)
							WHEN ISNUMERIC(@LogFrom) = 1 THEN DATEADD(DAY,CAST(@LogFrom AS INT) * -1 , CAST(@Log_Date AS DATE))
							ELSE CAST(@Log_Date AS DATE)
						END

	SELECT * 
	FROM Utility.ProcessLog
	WHERE 
		LogSource LIKE '%' + @Source + '%'
		AND LogDate >=  @Log_Date
	ORDER BY LogDate DESC, LogSource

END 

