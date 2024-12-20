CREATE PROC [Utility].[Get_PartitionMonthIDRange_String] @StartRange [VARCHAR](10),@EndRange [VARCHAR](10),@Partition_Ranges [VARCHAR](MAX) OUT AS 
/*
USE LND_TBOS 
GO
IF OBJECT_ID ('Utility.Get_PartitionMonthIDRange_String', 'P') IS NOT NULL DROP PROCEDURE Utility.Get_PartitionMonthIDRange_String
GO

###################################################################################################################
Example:
-------------------------------------------------------------------------------------------------------------------
DECLARE @Partition_Ranges VARCHAR(MAX)
EXEC Utility.Get_PartitionMonthIDRange_String 202001, NULL, @Partition_Ranges OUTPUT 
EXEC Utility.LongPrint @Partition_Ranges
===================================================================================================================
Proc Description: 
-------------------------------------------------------------------------------------------------------------------
This proc creating and returning string of all Values for partitioned table, Partitioned by MonthID, separated by comma
Values comes from Dim_Month table

@StartRange - Param to filter by date. 
	Can be:
		MonthID (int) - exact Month ID to start from
		Day ID (int) - exact day ID to start from
		Date - Date to start from
		String (Date in format YYYY-MM-DD) - Date to start from
		NULL - No Filter (first row in dbo.Dim_Month)
@EndRange - Param to filter by date. 
	Can be:
		MonthID (int) - exact Month ID to finish on
		Day ID (int) - exact day ID to finish on
		Date - Date to finish on
		String (Date in format YYYY-MM-DD) - Date to finish on
		NULL - No Filter (last row in dbo.Dim_Month)
@Partition_Ranges - Param to return string of values. 
===================================================================================================================
Change Log:
-------------------------------------------------------------------------------------------------------------------
CHG0037837			Andy	01/10/2020	New!
###################################################################################################################
*/

BEGIN
	/*====================================== TESTING =======================================================================*/
	--DECLARE @Partition_Ranges VARCHAR(MAX)
	/*====================================== TESTING =======================================================================*/
	DECLARE @Start_Date DATETIME2(3), @End_Date DATETIME2(3)
	
	SELECT 
		@Start_Date = CASE 
						WHEN ISNUMERIC(@StartRange) = 1 AND LEN(@StartRange) = 6 THEN CONVERT(DATE, @StartRange + '01', 112)
						WHEN ISNUMERIC(@StartRange) = 1 AND LEN(@StartRange) = 8 THEN CONVERT(DATE, @StartRange, 112)
						WHEN ISDATE(@StartRange) = 1 THEN CONVERT(DATE, @StartRange, 121)
						ELSE '2000-01-01'
					END,
		@End_Date = CASE 
						WHEN ISNUMERIC(@EndRange) = 1 AND LEN(@EndRange) = 6 THEN CONVERT(DATE, @EndRange + '01', 112)
						WHEN ISNUMERIC(@EndRange) = 1 AND LEN(@EndRange) = 8 THEN CONVERT(DATE, @EndRange, 112)
						WHEN ISDATE(@EndRange) = 1 THEN CONVERT(DATE, @EndRange, 121)
						ELSE CONVERT(VARCHAR(8),DATEADD(YEAR,1,GETDATE()), 112)
					END

	IF OBJECT_ID('tempDB..#TEMP_Dim_Month') IS NOT NULL DROP Table #TEMP_Dim_Month;

	SELECT MonthID, ROW_NUMBER() OVER (ORDER BY MonthID) AS Partition_Num
	INTO #TEMP_Dim_Month
	FROM dbo.Dim_Month
	WHERE MonthBeginDate BETWEEN @Start_Date AND @End_Date

	SET @Partition_Ranges = '' 
	DECLARE @TempVar VARCHAR(6)
	DECLARE @Num_Part INT = (SELECT MAX(Partition_Num) FROM #TEMP_Dim_Month)
	DECLARE @Cur_Part INT = 1
	DECLARE @Delimiter VARCHAR(3) = ''

	WHILE (@Cur_Part <= @Num_Part) BEGIN
		SELECT @TempVar = CAST(MonthID AS VARCHAR(6)) FROM #TEMP_Dim_Month WHERE Partition_Num = @Cur_Part
		SET @Partition_Ranges = @Partition_Ranges + @Delimiter + @TempVar
		SET	@Delimiter = ','
		SET @Cur_Part += 1
	END;
	/*====================================== TESTING =======================================================================*/
	--EXEC Utility.LongPrint @Partition_Ranges
	/*====================================== TESTING =======================================================================*/

END


