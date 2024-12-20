CREATE PROC [dbo].[Dim_Day_Hierarchy_Full_Load] AS
/*
###################################################################################################################
Purpose: Load all Date/Time dimension hierarchy tables. Run it once a year to load upto next year. 

Notes:
		- Rolling data Load of denormalized Date dimension tables at every Date hierarchy level
		- Consistent column naming and same shared data across all Date dim tables
		- Overlapping Star Schema Dimensional Model
		- Natural Hierarchies: 1) Day -> Month -> Quarter -> Year
							   2) Day -> Week
		- MicroStategy Design Theme: Join once from the fact table to any Level Date dim table and you are good! 
		- Level ID Column is the marker for the beginning of the group of columns for that Level
		- Robust set of Time Intelligence database transformations available at all levels towards the table end

Tables: !!! MATRYOSHKA RUSSIAN DOLLS ETL DESIGN PATTERN !!!
		- dbo.Dim_Year		-> Year level
		- dbo.Dim_Quarter	-> Quarter level + dbo.Dim_Year
		- dbo.Dim_Month		-> Month level + dbo.Dim_Quarter
		- dbo.Dim_Week		-> Week level + dbo.Dim_Month
		- dbo.Dim_Day		-> Day level + dbo.Dim_Week + dbo.Dim_Month
		- dbo.Dim_Time	    -> 24 Hours in HH MM SS level, in 5,10,15,30 min interval groups, in 12 and 24 HR format 
-------------------------------------------------------------------------------------------------------------------
Change Log:
-------------------------------------------------------------------------------------------------------------------
CHG0037838	Andy and Shankar	2020-06-04	New!
-------------------------------------------------------------------------------------------------------------------
Run script:
-------------------------------------------------------------------------------------------------------------------
EXEC dbo.Dim_Day_Hierarchy_Full_Load

EXEC Utility.FromLog 'dbo.Dim_Day', 1
SELECT 'dbo.Dim_Year' TableName, * FROM  dbo.Dim_Year ORDER BY 2 DESC 
SELECT 'dbo.Dim_Quarter' TableName, * FROM dbo.Dim_Quarter ORDER BY 2 DESC
SELECT 'dbo.Dim_Month' TableName, * FROM dbo.Dim_Month ORDER BY 2 DESC
SELECT 'dbo.Dim_Week' TableName, * FROM dbo.Dim_Week ORDER BY 2 DESC
SELECT 'dbo.Dim_Day' TableName, * FROM dbo.Dim_Day ORDER BY 2 DESC
SELECT 'dbo.Dim_Time' TableName, * FROM dbo.Dim_Time ORDER BY 2 DESC

--:: Duplicate check
SELECT 'dbo.Dim_Year' TableName, YearID, COUNT(1) RC FROM  dbo.Dim_Year GROUP BY YearID HAVING COUNT(1) > 1
SELECT 'dbo.Dim_Quarter' TableName, QuarterID, COUNT(1) RC FROM dbo.Dim_Quarter GROUP BY QuarterID HAVING COUNT(1) > 1
SELECT 'dbo.Dim_Month' TableName, MonthID, COUNT(1) RC FROM dbo.Dim_Month GROUP BY MonthID HAVING COUNT(1) > 1
SELECT 'dbo.Dim_Week' TableName, WeekID, COUNT(1) RC FROM dbo.Dim_Week GROUP BY WeekID HAVING COUNT(1) > 1
SELECT 'dbo.Dim_Day' TableName, DayID, COUNT(1) RC FROM dbo.Dim_Day GROUP BY DayID HAVING COUNT(1) > 1
SELECT 'dbo.Dim_Time' TableName, TimeID, COUNT(1) RC FROM dbo.Dim_Time GROUP BY TimeID HAVING COUNT(1) > 1

###################################################################################################################
*/

BEGIN

	BEGIN TRY

		DECLARE @Log_Source VARCHAR(100) = 'dbo.Dim_Day_Hierarchy_Full_Load', @Log_Start_Date DATETIME2 (3) = SYSDATETIME() 
		DECLARE @Log_Message VARCHAR(1000), @Row_Count BIGINT, @Trace_Flag BIT = 0 -- Testing
		EXEC    Utility.ToLog @Log_Source, @Log_Start_Date, 'Started full load of Hierarchy dim tables', '-1', NULL, 'I'

		--=============================================================================================================
		-- Load dbo.Dim_Year		->	Year Level
		--=============================================================================================================

		IF OBJECT_ID('dbo.Dim_Year_NEW') IS NOT NULL DROP TABLE dbo.Dim_Year_NEW
		CREATE TABLE dbo.Dim_Year_NEW WITH (CLUSTERED INDEX ( YearID ), DISTRIBUTION = REPLICATE)
			AS 
			SELECT 
					--:: Year Level
					 ISNULL(CAST(Cal_YearID AS SMALLINT), 0) AS YearID
					, CAST(YearDate AS DATE) AS YearBeginDate
					--:: All Time Intelligence attributes neatly packed at the end of the table. Primary level attribute columns come first for each level followed by these attributes. 
					, CAST(YearDuration AS SMALLINT) AS YearDuration
					, CAST(CASE WHEN Cal_PrevYearID  >= 2000 THEN Cal_PrevYearID  ELSE 0 END AS SMALLINT) AS P1YearID
					, CAST(CASE WHEN Cal_Prev2YearID >= 2000 THEN Cal_Prev2YearID ELSE 0 END AS SMALLINT) AS P2YearID
					, CAST(CASE WHEN Cal_Prev3YearID >= 2000 THEN Cal_Prev3YearID ELSE 0 END AS SMALLINT) AS P3YearID
					, CAST(CASE WHEN Cal_Prev4YearID >= 2000 THEN Cal_Prev4YearID ELSE 0 END AS SMALLINT) AS P4YearID
					, CAST(CASE WHEN Cal_Prev5YearID >= 2000 THEN Cal_Prev5YearID ELSE 0 END AS SMALLINT) AS P5YearID
					, CAST(CASE WHEN Cal_Prev6YearID >= 2000 THEN Cal_Prev6YearID ELSE 0 END AS SMALLINT) AS P6YearID
					, CAST(CASE WHEN Cal_Prev7YearID >= 2000 THEN Cal_Prev7YearID ELSE 0 END AS SMALLINT) AS P7YearID
					, GETDATE() AS LastModified
					-- SELECT *
			FROM Ref.Dim_Year  
			WHERE Cal_YearID <= YEAR(GETDATE())+1 
			OPTION (LABEL = 'Dim_Year Load');
	
		-- Log 
		SET  @Log_Message = 'Loaded dbo.Dim_Year with Year level'
		EXEC Utility.ToLog @Log_Source, @Log_Start_Date, @Log_Message, 'I',NULL,NULL
		
		-- Create statistics and swap table
		CREATE STATISTICS STATS_Dim_Year_01 ON dbo.Dim_Year_NEW (YearBeginDate);
		EXEC Utility.TableSwap 'dbo.Dim_Year_NEW', 'dbo.Dim_Year'

		IF @Trace_Flag = 1 SELECT TOP 100 'dbo.Dim_Year' TableName, * FROM dbo.Dim_Year ORDER BY 2 DESC

		--=============================================================================================================
		-- Load dbo.Dim_Quarter		->	 Quarter + Year levels
		--=============================================================================================================

		DECLARE @Q1_begin_date DATE  = '1/1/2000', @Q1_end_date DATE = '3/31/2000';
		IF OBJECT_ID('dbo.Dim_Quarter_NEW') IS NOT NULL DROP TABLE dbo.Dim_Quarter_NEW
		CREATE TABLE dbo.Dim_Quarter_NEW WITH (CLUSTERED INDEX ( QuarterID ), DISTRIBUTION = REPLICATE)
			AS 
			WITH CTE_QTR
				AS
				(
					SELECT
						CONVERT(DATE,DATEADD(QUARTER, N-1, @Q1_begin_date)) AS QuarterBeginDate,
						CONVERT(DATE,DATEADD(QUARTER, N-1, @Q1_end_date)) AS QuarterEndDate,
						LAG(CONVERT(DATE,DATEADD(QUARTER, N-1, @Q1_begin_date)),1,NULL) OVER(ORDER BY CONVERT(DATE,DATEADD(QUARTER, N-1, @Q1_begin_date))) P1QuarterBeginDate,
						LAG(CONVERT(DATE,DATEADD(QUARTER, N-1, @Q1_begin_date)),2,NULL) OVER(ORDER BY CONVERT(DATE,DATEADD(QUARTER, N-1, @Q1_begin_date))) P2QuarterBeginDate,
						LAG(CONVERT(DATE,DATEADD(QUARTER, N-1, @Q1_begin_date)),3,NULL) OVER(ORDER BY CONVERT(DATE,DATEADD(QUARTER, N-1, @Q1_begin_date))) P3QuarterBeginDate,
						LAG(CONVERT(DATE,DATEADD(QUARTER, N-1, @Q1_begin_date)),4,NULL) OVER(ORDER BY CONVERT(DATE,DATEADD(QUARTER, N-1, @Q1_begin_date))) P4QuarterBeginDate
					FROM Utility.Number N
					WHERE N <= 200
				)
				SELECT
					--:: Quarter Level
					CONVERT(INT,CONVERT(VARCHAR(4),YEAR(QuarterBeginDate)) + CONVERT(VARCHAR(1),ROW_NUMBER() OVER (PARTITION BY YEAR(QuarterBeginDate) ORDER BY QuarterBeginDate))) QuarterID,
					CTE_QTR.QuarterBeginDate, 
					CTE_QTR.QuarterEndDate, 
					CONVERT(VARCHAR(7),CONVERT(VARCHAR(4),YEAR(QuarterBeginDate)) + ' Q' + CONVERT(VARCHAR(1),ROW_NUMBER() OVER (PARTITION BY YEAR(QuarterBeginDate) ORDER BY QuarterBeginDate))) YearQuarterDesc,
					CONVERT(VARCHAR(7),'Q' + CONVERT(VARCHAR(1),ROW_NUMBER() OVER (PARTITION BY YEAR(QuarterBeginDate) ORDER BY QuarterBeginDate))) + ' ' + CONVERT(VARCHAR(4),YEAR(QuarterBeginDate)) QuarterYearDesc,
					CONVERT(VARCHAR(2),'Q' + CONVERT(VARCHAR(1),ROW_NUMBER() OVER (PARTITION BY YEAR(QuarterBeginDate) ORDER BY QuarterBeginDate))) QuarterDesc,
					DATEDIFF(DAY,QuarterBeginDate,QuarterEndDate)+1 QuarterDuration,
					--:: Year Level
					CONVERT(SMALLINT,YEAR(QuarterBeginDate)) YearID,
					Y.YearBeginDate, Y.YearDuration,
					--:: All Time Intelligence attributes neatly packed at the end of the table. Primary level attribute columns come first for each level followed by these attributes. 
					--:: Quarter
					CONVERT(INT,ISNULL(CONVERT(VARCHAR(4),YEAR(P1QuarterBeginDate)) + CONVERT(VARCHAR(1),DATEPART(QUARTER,P1QuarterBeginDate)),'0')) P1QuarterID,
					CONVERT(INT,ISNULL(CONVERT(VARCHAR(4),YEAR(P2QuarterBeginDate)) + CONVERT(VARCHAR(1),DATEPART(QUARTER,P2QuarterBeginDate)),'0')) P2QuarterID,
					CONVERT(INT,ISNULL(CONVERT(VARCHAR(4),YEAR(P3QuarterBeginDate)) + CONVERT(VARCHAR(1),DATEPART(QUARTER,P3QuarterBeginDate)),'0')) P3QuarterID,
					CONVERT(INT,ISNULL(CONVERT(VARCHAR(4),YEAR(P4QuarterBeginDate)) + CONVERT(VARCHAR(1),DATEPART(QUARTER,P4QuarterBeginDate)),'0')) P4QuarterID,
					CONVERT(INT,ISNULL(CONVERT(VARCHAR(4),YEAR(P4QuarterBeginDate)) + CONVERT(VARCHAR(1),DATEPART(QUARTER,P4QuarterBeginDate)),'0')) LY1QuarterID, -- LY ids are YOY ids. Same as P4QuarterID in this case.
					--:: Year
					Y.P1YearID, Y.P2YearID, Y.P3YearID, Y.P4YearID, Y.P5YearID, Y.P6YearID, Y.P7YearID,
					GETDATE() AS LastModified
				FROM CTE_QTR 
				JOIN dbo.Dim_Year Y ON Y.YearID = CONVERT(SMALLINT,YEAR(CTE_QTR.QuarterBeginDate))
				WHERE YEAR(QuarterBeginDate) BETWEEN 2000 AND 2030

				UNION ALL

				SELECT 19001, N'1900-01-01T00:00:00', N'1900-03-31T00:00:00', '1900 Q1', 'Q1 1900', 'Q1', 91, YearID, YearBeginDate, YearDuration, 0 P1QuarterID, 0 P2QuarterID, 0 P3QuarterID, 0 P4QuarterID, 0 LY1QuarterID, P1YearID, P2YearID, P3YearID, P4YearID, P5YearID, P6YearID, P7YearID,LastModified
				FROM dbo.Dim_Year
				WHERE YearID = 1900

				OPTION (LABEL = 'Dim_Quarter Load');

		-- Log
		SET  @Log_Message = 'Loaded dbo.Dim_Quarter with Quarter Level + dbo.Dim_Year'
		EXEC Utility.ToLog @Log_Source, @Log_Start_Date, @Log_Message, 'I',NULL,NULL

		-- Create statistics and swap table
		CREATE STATISTICS STATS_Dim_Quarter_01 ON dbo.Dim_Quarter_NEW (YearID);
		CREATE STATISTICS STATS_Dim_Quarter_02 ON dbo.Dim_Quarter_NEW (YearID, QuarterID); 
 		EXEC Utility.TableSwap 'dbo.Dim_Quarter_NEW', 'dbo.Dim_Quarter'

		IF @Trace_Flag = 1 SELECT TOP 100 'dbo.Dim_Quarter' TableName, * FROM dbo.Dim_Quarter ORDER BY 2 DESC

		--=============================================================================================================
		-- Load dbo.Dim_Month		->	 Month + Quarter + Year levels
		--=============================================================================================================

		IF OBJECT_ID('dbo.Dim_Month_NEW') IS NOT NULL DROP TABLE dbo.Dim_Month_NEW

		CREATE TABLE dbo.Dim_Month_NEW WITH (CLUSTERED INDEX ( MonthID ), DISTRIBUTION = REPLICATE)
			AS 
			SELECT 
					--:: Month Level
					 ISNULL(CAST(main_table.Cal_MonthID AS int), 0) AS MonthID
					, CAST(main_table.MonthDate AS date) AS MonthBeginDate
					, CAST(EOMONTH(MonthDate) AS date) AS MonthEndDate
					, CAST(RIGHT(main_table.MonthDesc,4) + ' ' + LEFT(main_table.MonthDesc,3) AS varchar(10)) AS YearMonthDesc
					, CAST(LEFT(main_table.MonthDesc,3) + ' ' + RIGHT(main_table.MonthDesc,4) AS varchar(10)) AS MonthYearDesc
					, CAST(DATENAME(mm,MonthDate) AS varchar(10)) AS MonthDesc
					, CAST(main_table.Cal_MonthOfYear AS tinyint) AS MonthOfYear
					, CAST(main_table.MonthDuration AS tinyint) AS MonthDuration
					--:: Quarter, Year Levels
					, Q.QuarterID, Q.QuarterBeginDate, Q.QuarterEndDate, Q.YearQuarterDesc, Q.QuarterYearDesc, Q.QuarterDesc, Q.QuarterDuration
					, Q.YearID, Q.YearBeginDate, Q.YearDuration 

					--:: All Time Intelligence attributes neatly packed at the end of the table. Primary level attribute columns come first for each level followed by these attributes.
					, CAST(CASE WHEN DATEADD(MONTH,-1,  MonthDate) >= '1/1/2000' THEN CONVERT(VARCHAR(6),DATEADD(MONTH,-1,  MonthDate) ,112) ELSE 0 END AS INT) AS P1MonthID
					, CAST(CASE WHEN DATEADD(MONTH,-2,  MonthDate) >= '1/1/2000' THEN CONVERT(VARCHAR(6),DATEADD(MONTH,-2,  MonthDate) ,112) ELSE 0 END AS INT) AS P2MonthID
					, CAST(CASE WHEN DATEADD(MONTH,-3,  MonthDate) >= '1/1/2000' THEN CONVERT(VARCHAR(6),DATEADD(MONTH,-3,  MonthDate) ,112) ELSE 0 END AS INT) AS P3MonthID
					, CAST(CASE WHEN DATEADD(MONTH,-4,  MonthDate) >= '1/1/2000' THEN CONVERT(VARCHAR(6),DATEADD(MONTH,-4,  MonthDate) ,112) ELSE 0 END AS INT) AS P4MonthID
					, CAST(CASE WHEN DATEADD(MONTH,-5,  MonthDate) >= '1/1/2000' THEN CONVERT(VARCHAR(6),DATEADD(MONTH,-5,  MonthDate) ,112) ELSE 0 END AS INT) AS P5MonthID
					, CAST(CASE WHEN DATEADD(MONTH,-6,  MonthDate) >= '1/1/2000' THEN CONVERT(VARCHAR(6),DATEADD(MONTH,-6,  MonthDate) ,112) ELSE 0 END AS INT) AS P6MonthID
					, CAST(CASE WHEN DATEADD(MONTH,-7,  MonthDate) >= '1/1/2000' THEN CONVERT(VARCHAR(6),DATEADD(MONTH,-7,  MonthDate) ,112) ELSE 0 END AS INT) AS P7MonthID
					, CAST(CASE WHEN DATEADD(MONTH,-8,  MonthDate) >= '1/1/2000' THEN CONVERT(VARCHAR(6),DATEADD(MONTH,-8,  MonthDate) ,112) ELSE 0 END AS INT) AS P8MonthID
					, CAST(CASE WHEN DATEADD(MONTH,-9,  MonthDate) >= '1/1/2000' THEN CONVERT(VARCHAR(6),DATEADD(MONTH,-9,  MonthDate) ,112) ELSE 0 END AS INT) AS P9MonthID
					, CAST(CASE WHEN DATEADD(MONTH,-10, MonthDate) >= '1/1/2000' THEN CONVERT(VARCHAR(6),DATEADD(MONTH,-10, MonthDate) ,112) ELSE 0 END AS INT) AS P10MonthID
					, CAST(CASE WHEN DATEADD(MONTH,-11, MonthDate) >= '1/1/2000' THEN CONVERT(VARCHAR(6),DATEADD(MONTH,-11, MonthDate) ,112) ELSE 0 END AS INT) AS P11MonthID
					, CAST(CASE WHEN DATEADD(MONTH,-12, MonthDate) >= '1/1/2000' THEN CONVERT(VARCHAR(6),DATEADD(MONTH,-12, MonthDate) ,112) ELSE 0 END AS INT) AS P12MonthID
					, CAST(CASE WHEN DATEADD(MONTH,-12, MonthDate) >= '1/1/2000' THEN CONVERT(VARCHAR(6),DATEADD(MONTH,-12, MonthDate) ,112) ELSE 0 END AS INT) AS LY1MonthID
					, Q.P1QuarterID, Q.P2QuarterID, Q.P3QuarterID, Q.P4QuarterID, Q.LY1QuarterID -- Quarter Time Intelligence
					, Q.P1YearID, Q.P2YearID, Q.P3YearID, Q.P4YearID, Q.P5YearID, Q.P6YearID, Q.P7YearID  -- Year Time Intelligence
					, GETDATE() AS LastModified
			--SELECT *
			FROM Ref.Dim_Month AS main_table
			JOIN dbo.Dim_Quarter Q ON main_table.Cal_QuarterID = Q.QuarterID
			OPTION (LABEL = 'Dim_Month Load');
		
		-- Log
		SET  @Log_Message = 'Loaded dbo.Dim_Month with Month level + dbo.Dim_Quarter'
		EXEC Utility.ToLog @Log_Source, @Log_Start_Date, @Log_Message, 'I',NULL,NULL

		-- Create statistics and swap table
		CREATE STATISTICS STATS_Dim_Month_01 ON dbo.Dim_Month_NEW (MonthID);
		CREATE STATISTICS STATS_Dim_Month_02 ON dbo.Dim_Month_NEW (QuarterID);
		CREATE STATISTICS STATS_Dim_Month_03 ON dbo.Dim_Month_NEW (YearID);
		CREATE STATISTICS STATS_Dim_Month_04 ON dbo.Dim_Month_NEW (MonthBeginDate);
		EXEC Utility.TableSwap 'dbo.Dim_Month_NEW', 'dbo.Dim_Month'

		IF @Trace_Flag = 1 SELECT TOP 100 'dbo.Dim_Month' TableName, * FROM dbo.Dim_Month ORDER BY 2 DESC

		--=============================================================================================================
		-- Load dbo.Dim_Week		->	 Week + Month + Quarter + Year levels
		--=============================================================================================================
		IF OBJECT_ID('dbo.Dim_Week_NEW') IS NOT NULL DROP TABLE dbo.Dim_Week_NEW
		CREATE TABLE dbo.Dim_Week_NEW WITH (CLUSTERED INDEX ( WeekID ), DISTRIBUTION = REPLICATE)
			AS 
			WITH CTE1 AS
			(
				SELECT DISTINCT CAST(DATENAME(YEAR,DayDate) + RIGHT('0' + DATENAME(Week,DayDate),2) AS INT) AS WeekID
						,DATEADD(DAY, (1 - DATEPART(WEEKDAY,DayDate))  ,DayDate) AS WeekBeginDate
						,DATEADD(DAY, 7 - DATEPART(WEEKDAY,DayDate)  ,DayDate) AS WeekEndDate
						,DATEPART(Week,DayDate) AS WeekOfYear
						,Cal_MonthID AS MonthID
						,Cal_YearID AS YearID
				FROM Ref.Dim_Day
				WHERE DayID <> 19000101
			)
			, CTE2 AS
			(
				SELECT	 WeekID
						,WeekOfYear
						,CASE WHEN DATEPART(YEAR,WeekBeginDate) < YearID -- Prev year
							THEN CAST(CAST(YearID AS VARCHAR(4)) + '-01-01' AS DATE)
							ELSE WeekBeginDate
						 END AS WeekBeginDate
						,CASE WHEN DATEPART(YEAR,WeekEndDate) > YearID -- Prev year
							THEN CAST(CAST(YearID AS VARCHAR(4)) + '-12-31' AS DATE)
							ELSE WeekEndDate
						 END AS WeekEndDate
						,MonthID
						,ROW_NUMBER() OVER (PARTITION BY WeekID ORDER BY MonthID) RowNum

				FROM CTE1
			)
 
			SELECT
				--:: Week Level
				WeekID
				,WeekBeginDate
				,WeekEndDate
				,CONVERT(VARCHAR(10), WeekBeginDate,101) + ' - ' + CONVERT(VARCHAR(10), WeekEndDate,101) AS WeekDesc
				,WeekOfYear
				--:: Higher Levels. Important note: This is informational only. Week is not part of a natural hierarchy to higher levels
				,M.MonthID, M.MonthBeginDate, M.MonthEndDate, M.YearMonthDesc, M.MonthYearDesc, M.MonthDesc, M.MonthOfYear, M.MonthDuration 
				,M.QuarterID, M.QuarterBeginDate, M.QuarterEndDate, M.YearQuarterDesc, M.QuarterYearDesc, M.QuarterDesc, M.QuarterDuration 
				,M.YearID, M.YearBeginDate, M.YearDuration 
		
				--:: All Time Intelligence attributes neatly packed at the end of the table. Primary level attribute columns come first for each level followed by these attributes. 
				,LAG(CONVERT(INT,CONVERT(VARCHAR(4),YearID)+ RIGHT('0' + CONVERT(VARCHAR(2),WeekOfYear),2)),1,0) OVER (ORDER BY WeekID) P1WeekID
				,LAG(CONVERT(INT,CONVERT(VARCHAR(4),YearID)+ RIGHT('0' + CONVERT(VARCHAR(2),WeekOfYear),2)),2,0) OVER (ORDER BY WeekID) P2WeekID
				,LAG(CONVERT(INT,CONVERT(VARCHAR(4),YearID)+ RIGHT('0' + CONVERT(VARCHAR(2),WeekOfYear),2)),3,0) OVER (ORDER BY WeekID) P3WeekID
				,LAG(CONVERT(INT,CONVERT(VARCHAR(4),YearID)+ RIGHT('0' + CONVERT(VARCHAR(2),WeekOfYear),2)),4,0) OVER (ORDER BY WeekID) P4WeekID
				--!Note! Week is NOT part of a natural hierarchy to higher levels. Intentionally excluded other level Time Intelligence attributes and left them for future addition.
				,GETDATE() AS LastModified
			FROM CTE2
			JOIN dbo.Dim_Month M ON CTE2.MonthID = M.MonthID
			WHERE RowNum = 1
			UNION ALL
		
			SELECT	190001 WeekID, '1900-01-01' WeekBeginDate, '1900-01-06' WeekEndDate, '01/01/1900 - 01/06/1900' WeekDesc, 1 WeekOfYear, 
					MonthID, MonthBeginDate, MonthEndDate, YearMonthDesc, MonthYearDesc, MonthDesc, MonthOfYear, MonthDuration, QuarterID, QuarterBeginDate, QuarterEndDate, YearQuarterDesc, QuarterYearDesc, QuarterDesc, QuarterDuration, YearID, YearBeginDate, YearDuration, 0 P1WeekID, 0 P2WeekID, 0 P3WeekID, 0 P4WeekID, LastModified
			FROM	dbo.Dim_Month 
			WHERE	MonthID = 190001

			OPTION (LABEL = 'Dim_Week Load');

		-- Log
		SET  @Log_Message = 'Loaded dbo.Dim_Week with Week level + dbo.Dim_Month'
		EXEC Utility.ToLog @Log_Source, @Log_Start_Date, @Log_Message,'I',NULL,NULL

		-- Create statistics and swap table
		CREATE STATISTICS STATS_Dim_Week_01 ON dbo.Dim_Week_NEW (WeekBeginDate, WeekEndDate);
		EXEC Utility.TableSwap 'dbo.Dim_Week_NEW', 'dbo.Dim_Week'

		IF @Trace_Flag = 1 SELECT TOP 100 'dbo.Dim_Week' TableName, * FROM dbo.Dim_Week ORDER BY 2 DESC

		--=============================================================================================================
		-- Load dbo.Dim_Day		->	 Day + Week + Month + Quarter + Year levels
		--=============================================================================================================

		IF OBJECT_ID('dbo.Dim_Day_NEW') IS NOT NULL DROP TABLE dbo.Dim_Day_NEW
		CREATE TABLE dbo.Dim_Day_NEW WITH (CLUSTERED INDEX ( DayID ), DISTRIBUTION = REPLICATE)
			AS 
			SELECT 
					--:: Day Level
					  CONVERT(INT, ISNULL(main_table.DayID,-1)) AS DayID
					, CONVERT(DATE,ISNULL(main_table.DayDate,'1900-01-01')) AS DayDate
					, CONVERT(VARCHAR(18),CONVERT(VARCHAR(12), DayDate,107) + ' (' + LEFT(DATENAME(dw,DayDate),3) + ')') AS DayDesc
					, CONVERT(VARCHAR(10),DATENAME(dw,main_table.DayDate)) AS DayName
					, DAY(main_table.DayDate) DayOfMonth
					, DATEPART(DAYOFYEAR,main_table.DayDate) DayOfYear
					, CONVERT(BIT,main_table.IsWeekDay) AS IsWeekDay
					, CONVERT(BIT,main_table.IsWeekEnd) AS IsWeekEnd
					, CONVERT(BIT,CASE WHEN Dim_Date.BUSINESS_DAY = 'Yes' THEN 1 ELSE 0 END) AS IsBusinessday
					, CONVERT(BIT,CASE WHEN Dim_Date.HOLIDAY = 'Yes' AND main_table.DayID <> 19000101 THEN 1 ELSE 0 END) AS IsHoliday
					, CONVERT(VARCHAR(60), CASE WHEN main_table.DayID <> 19000101 THEN Dim_Date.HOLIDAY_NAME END) HolidayName

					--:: Week Level
					, W.WeekID, W.WeekBeginDate, W.WeekEndDate, W.WeekDesc, W.WeekOfYear
					--:: Month + Quarter + Year Levels
					, M.MonthID, M.MonthBeginDate, M.MonthEndDate, m.YearMonthDesc, M.MonthYearDesc, M.MonthDesc, M.MonthOfYear, M.MonthDuration
					, M.QuarterID, M.QuarterBeginDate, M.QuarterEndDate, M.YearQuarterDesc, M.QuarterYearDesc, M.QuarterDesc, M.QuarterDuration
					, M.YearID, M.YearBeginDate, M.YearDuration
			
					--:: All Time Intelligence attributes neatly packed at the end of the table. Primary level attribute columns come first for each level followed by these attributes. 
					--:: Day Intelligence
					, CAST(main_table.PrevDayID AS INT)                             AS P1DayID
					, CAST(CONVERT(VARCHAR(8),DATEADD(DAY,-2, DayDate),112) AS INT) AS P2DayID
					, CAST(CONVERT(VARCHAR(8),DATEADD(DAY,-3, DayDate),112) AS INT) AS P3DayID
					, CAST(CONVERT(VARCHAR(8),DATEADD(DAY,-3, DayDate),112) AS INT) AS P4DayID
					, CAST(CONVERT(VARCHAR(8),DATEADD(DAY,-3, DayDate),112) AS INT) AS P5DayID
					, CAST(CONVERT(VARCHAR(8),DATEADD(DAY,-3, DayDate),112) AS INT) AS P6DayID
					, CAST(CONVERT(VARCHAR(8),DATEADD(DAY,-3, DayDate),112) AS INT) AS P7DayID
					--:: Week Intelligence
					, W.P1WeekID, W.P2WeekID, W.P3WeekID, W.P4WeekID
					--:: Month + Quarter + Year Intelligence
					, M.P1MonthID, M.P2MonthID, M.P3MonthID, M.P4MonthID, M.P5MonthID, M.P6MonthID, M.P7MonthID, M.P8MonthID, M.P9MonthID, M.P10MonthID, M.P11MonthID, M.P12MonthID
					, M.P1QuarterID, M.P2QuarterID, M.P3QuarterID, M.P4QuarterID, M.LY1QuarterID
					, M.P1YearID, M.P2YearID, M.P3YearID, M.P4YearID, M.P5YearID, M.P6YearID, M.P7YearID
					, GETDATE() AS LastModified
			--SELECT *
			FROM Ref.Dim_Day AS main_table
			LEFT JOIN dbo.Dim_Week W ON W.WeekID = CONVERT(INT,LEFT(CONVERT(VARCHAR,main_table.Cal_WeekID),4) + RIGHT(CONVERT(VARCHAR,main_table.Cal_WeekID),2)) -- Changed WeekID from YYYYWWW to YYYYWW since there are only 52 weeks in a year. Example: 2020045 to 202045
			JOIN  dbo.Dim_Month M ON main_table.Cal_MonthID = M.MonthID
			LEFT JOIN Ref.Dim_Date AS Dim_Date ON Dim_Date.DATE = main_table.DayDate
			OPTION (LABEL = 'Dim_Day Load');
		
		-- Log
		SET  @Log_Message = 'Loaded dbo.Dim_Day with Day level + dbo.Dim_Week + dbo.Dim_Month'
		EXEC Utility.ToLog @Log_Source, @Log_Start_Date, @Log_Message, 'I',NULL,NULL

		-- Create statistics and swap table
		CREATE STATISTICS STATS_Dim_Day_01 ON dbo.Dim_Day_NEW (DayDate);
		CREATE STATISTICS STATS_Dim_Day_02 ON dbo.Dim_Day_NEW (MonthID);
		CREATE STATISTICS STATS_Dim_Day_03 ON dbo.Dim_Day_NEW (WeekID);
		CREATE STATISTICS STATS_Dim_Day_04 ON dbo.Dim_Day_NEW (QuarterID);
		CREATE STATISTICS STATS_Dim_Day_05 ON dbo.Dim_Day_NEW (YearID);
		CREATE STATISTICS STATS_Dim_Day_06 ON dbo.Dim_Day_NEW (YearID, MonthID, QuarterID, DayID);
		CREATE STATISTICS STATS_Dim_Day_07 ON dbo.Dim_Day_NEW (WeekID, DayID);
		EXEC Utility.TableSwap 'dbo.Dim_Day_NEW', 'dbo.Dim_Day'

		IF @Trace_Flag = 1 SELECT TOP 100 'dbo.Dim_Day' TableName, * FROM dbo.Dim_Day ORDER BY 2 DESC
									 
		--=============================================================================================================
		-- Load dbo.Dim_Time
		--=============================================================================================================
		IF OBJECT_ID('dbo.Dim_Time_NEW') IS NOT NULL DROP TABLE dbo.Dim_Time_NEW
		CREATE TABLE dbo.Dim_Time_NEW WITH (CLUSTERED INDEX ( TimeID ), DISTRIBUTION = REPLICATE)
			AS 
			SELECT 
					 ISNULL(CAST(TIME_ID AS int), 0) AS TimeID
					, ISNULL(CAST([HOUR] AS varchar(6)), '') AS [Hour]
					, ISNULL(CAST([MINUTE] AS varchar(6)), '') AS [Minute]
					, ISNULL(CAST([SECOND] AS varchar(6)), '') AS [Second]
					, ISNULL(CAST([12_HOUR] AS varchar(6)), '') AS [12_Hour]
					, ISNULL(CAST([AM_PM] AS varchar(6)), '') AS [AM_PM]
					, ISNULL(CAST([5_MINUTE] AS varchar(6)), '') AS [5_Minute]
					, ISNULL(CAST([10_MINUTE] AS varchar(6)), '') AS [10_Minute]
					, ISNULL(CAST([15_MINUTE] AS varchar(6)), '') AS [15_Minute]
					, ISNULL(CAST([30_MINUTE] AS varchar(6)), '') AS [30_Minute]
					, GETDATE() AS LastModified
					-- SELECT *
			FROM Ref.Dim_Time 
			OPTION (LABEL = 'Dim_Time Load');

		-- Log
		SET  @Log_Message = 'Loaded dbo.Dim_Time'
		EXEC Utility.Row_Count @Row_Count = @Row_Count OUTPUT
		EXEC Utility.ToLog @Log_Source, @Log_Start_Date, @Log_Message, '-1', @Row_Count, 'I'

		-- Create statistics and swap table
		CREATE STATISTICS STATS_Dim_Time_01 ON dbo.Dim_Time_NEW ([HOUR], [MINUTE], [SECOND]);
		EXEC Utility.TableSwap 'dbo.Dim_Time_NEW', 'dbo.Dim_Time'

		-- Show results
		IF @Trace_Flag = 1 SELECT TOP 100 'dbo.Dim_Time' TableName, * FROM dbo.Dim_Time ORDER BY 2 DESC
		IF @Trace_Flag = 1 EXEC Utility.FromLog @Log_Source, @Log_Start_Date

		EXEC Utility.ToLog @Log_Source, @Log_Start_Date, 'Completed full load of Date/Time Hierarchy dim tables', 'I',NULL,NULL
	
	END	TRY	

	BEGIN CATCH
		
		DECLARE @Error_Message VARCHAR(MAX) = ERROR_MESSAGE();
		EXEC    Utility.ToLog @Log_Source, @Log_Start_Date, @Error_Message, 'E',NULL, NULL;
		EXEC	Utility.FromLog @Log_Source, @Log_Start_Date;
		THROW;  -- Rethrow the error all the way to Data Manager
	
	END CATCH
END

/*

--:: Testing Zone

EXEC dbo.Dim_Day_Hierarchy_Full_Load

SELECT * FROM Utility.ProcessLog 
WHERE LogDate > '2020-07-30' AND LogSource IN ('dbo.Dim_Time','dbo.Dim_Day','dbo.Dim_Week','dbo.Dim_Month','dbo.Dim_Quarter','dbo.Dim_Year') 
ORDER BY LogDate DESC

--:: Quick check
SELECT * FROM Ref.Dim_Year ORDER BY 1
SELECT * FROM dbo.Dim_Year ORDER BY 1

--:: Quick check
SELECT * FROM Ref.Dim_Quarter ORDER BY 1
SELECT * FROM dbo.Dim_Quarter ORDER BY 1

--:: Quick check
SELECT * FROM Ref.Dim_Month ORDER BY 1
SELECT * FROM dbo.Dim_Month ORDER BY 1

--:: Quick check
SELECT * FROM Ref.Dim_Week ORDER BY 1
SELECT * FROM dbo.Dim_Week ORDER BY 1

--:: Quick check
SELECT * FROM Ref.Dim_Day ORDER BY 1
SELECT * FROM dbo.Dim_Day ORDER BY 1

--:: Quick check
SELECT * FROM Ref.Dim_Time ORDER BY 1
SELECT * FROM dbo.Dim_Time ORDER BY 1

--:: Data Profiling

SELECT MIN(DAYID) MIN_DAYID, MAX(DAYID) MAX_DAYID, COUNT(1) ROW_CNT FROM Ref.Dim_Day WHERE DAYID <>19000101  ORDER BY 1
SELECT MIN(Cal_MonthID) MIN_Cal_MonthID, MAX(Cal_MonthID) MAX_Cal_MonthID, COUNT(1) ROW_CNT FROM Ref.Dim_Month WHERE Cal_MonthID<> 190001  ORDER BY 1
SELECT MIN(Cal_QuarterID) MIN_Cal_QuarterID, MAX(Cal_QuarterID) MAX_Cal_QuarterID, COUNT(1) ROW_CNT FROM Ref.Dim_Quarter WHERE Cal_QuarterID <> 19001 ORDER BY 1
SELECT MIN(Cal_YearID) MIN_Cal_YearID, MAX(Cal_YearID) MAX_Cal_YearID, COUNT(1) ROW_CNT FROM Ref.Dim_Year WHERE Cal_YearID <> 1900 ORDER BY 1

SELECT IsWorkDay, *
FROM Ref.Dim_Day AS main_table
LEFT JOIN Ref.Dim_Date AS Dim_Date ON Dim_Date.DATE = DayDate 
WHERE Dim_Date.BUSINESS_DAY = Dim_Date.HOLIDAY AND  Dim_Date.HOLIDAY = 'No'
--WHERE IsWorkDay = CASE WHEN Dim_Date.BUSINESS_DAY = 'Yes' THEN 1 ELSE 0 END

*/

