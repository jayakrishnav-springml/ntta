CREATE VIEW [dbo].[vw_Ban_ActionDate] AS SELECT  
		[DATE]					AS ActionDate 
	, MONTH_WEEK				AS ActionDateMonthWeek
	, DATE_FULL					AS ActionDateDateStr 
	, DATE_YEAR_MONTH			AS ActionDateYearMonth
	, DATE_QUARTER				AS ActionDateQuarter
	, DATE_YEAR					AS ActionDateYear
FROM dbo.DIM_DATE;
