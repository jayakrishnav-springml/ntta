CREATE PROC [dbo].[Dim_Day_Hierarchy_Nagios_Full_Load] AS
/*
###################################################################################################################
Purpose: Loads all Date/Time dimension hierarchy tables at the beginning of each year.

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
CHG0039845	Andy and Shankar	2020-06-04	New!
-------------------------------------------------------------------------------------------------------------------
Run script:
-------------------------------------------------------------------------------------------------------------------
EXEC dbo.Dim_Day_Hierarchy_Nagios_Full_Load

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
		SELECT * FROM EDW_TRIPS.dbo.Dim_Year
		OPTION (LABEL = 'EDW_NAGIOS.dbo.Dim_Year Load');

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

		IF OBJECT_ID('dbo.Dim_Quarter_NEW') IS NOT NULL DROP TABLE dbo.Dim_Quarter_NEW
		CREATE TABLE dbo.Dim_Quarter_NEW WITH (CLUSTERED INDEX ( QuarterID ), DISTRIBUTION = REPLICATE)
			AS 
		SELECT * FROM EDW_TRIPS.dbo.Dim_Quarter
		OPTION (LABEL = 'EDW_NAGIOS.dbo.Dim_Quarter Load');

		-- Log 
		SET  @Log_Message = 'Loaded dbo.Dim_Quarter with Quarter level'
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
		SELECT * FROM EDW_TRIPS.dbo.Dim_Month
		OPTION (LABEL = 'EDW_NAGIOS.dbo.Dim_Month Load');

		-- Log 
		SET  @Log_Message = 'Loaded dbo.Dim_Month with Month level'
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
		SELECT * FROM EDW_TRIPS.dbo.Dim_Week
		OPTION (LABEL = 'EDW_NAGIOS.dbo.Dim_Week Load');

		-- Log 
		SET  @Log_Message = 'Loaded dbo.Dim_Week with Week level'
		EXEC Utility.ToLog @Log_Source, @Log_Start_Date, @Log_Message, 'I',NULL,NULL

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
		SELECT * FROM EDW_TRIPS.dbo.Dim_Day
		OPTION (LABEL = 'EDW_NAGIOS.dbo.Dim_Day Load');

		-- Log 
		SET  @Log_Message = 'Loaded dbo.Dim_Day with Day level'
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
		SELECT * FROM EDW_TRIPS.dbo.Dim_Time
		OPTION (LABEL = 'EDW_NAGIOS.dbo.Dim_Time Load');

		-- Log 
		SET  @Log_Message = 'Loaded dbo.Dim_Time with Time level'
		EXEC Utility.ToLog @Log_Source, @Log_Start_Date, @Log_Message, 'I',NULL,NULL

		-- Create statistics and swap table
		CREATE STATISTICS STATS_Dim_Time_01 ON dbo.Dim_Time_NEW ([HOUR], [MINUTE], [SECOND]);
		EXEC Utility.TableSwap 'dbo.Dim_Time_NEW', 'dbo.Dim_Time'

		IF @Trace_Flag = 1 SELECT TOP 100 'dbo.Dim_Time' TableName, * FROM dbo.Dim_Time ORDER BY 2 DESC

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
SELECT * FROM EDW_TRIPS.dbo.Dim_Year ORDER BY 1
SELECT * FROM dbo.Dim_Year ORDER BY 1

--:: Quick check
SELECT * FROM EDW_TRIPS.dbo.Dim_Quarter ORDER BY 1
SELECT * FROM dbo.Dim_Quarter ORDER BY 1

--:: Quick check
SELECT * FROM EDW_TRIPS.dbo.Dim_Month ORDER BY 1
SELECT * FROM dbo.Dim_Month ORDER BY 1

--:: Quick check
SELECT * FROM EDW_TRIPS.dbo.Dim_Week ORDER BY 1
SELECT * FROM dbo.Dim_Week ORDER BY 1

--:: Quick check
SELECT * FROM EDW_TRIPS.dbo.Dim_Day ORDER BY 1
SELECT * FROM dbo.Dim_Day ORDER BY 1

--:: Quick check
SELECT * FROM EDW_TRIPS.dbo.Dim_Time ORDER BY 1
SELECT * FROM dbo.Dim_Time ORDER BY 1
*/
