CREATE VIEW [dbo].[vw_Vrb_AppliedDate] AS SELECT  
		[DATE]					AS AppliedDate 
	, MONTH_WEEK				AS AppliedDateMonthWeek
	, DATE_FULL					AS AppliedDateDateStr 
	, DATE_YEAR_MONTH			AS AppliedDateYearMonth
	, DATE_QUARTER				AS AppliedDateQuarter
	, DATE_YEAR					AS AppliedDateYear
FROM dbo.DIM_DATE;
