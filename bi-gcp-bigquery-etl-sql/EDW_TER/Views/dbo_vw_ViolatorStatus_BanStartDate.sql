CREATE VIEW [dbo].[vw_ViolatorStatus_BanStartDate] AS SELECT  
	  [DATE]			AS BanStartDate 
	, MONTH_WEEK		AS BanStartDateMonthWeek
	, DATE_FULL			AS BanStartDateDateStr 
	, DATE_YEAR_MONTH	AS BanStartDateYearMonth
	, DATE_QUARTER		AS BanStartDateQuarter
	, DATE_YEAR			AS BanStartDateYear
FROM dbo.DIM_DATE;
