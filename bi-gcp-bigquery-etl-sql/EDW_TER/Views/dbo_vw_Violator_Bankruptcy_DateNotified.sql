CREATE VIEW [dbo].[vw_Violator_Bankruptcy_DateNotified] AS SELECT  
		[DATE]					AS DateNotified 
	, MONTH_WEEK				AS DateNotifiedMonthWeek
	, DATE_FULL					AS DateNotifiedDateStr 
	, DATE_YEAR_MONTH			AS DateNotifiedYearMonth
	, DATE_QUARTER				AS DateNotifiedQuarter
	, DATE_YEAR					AS DateNotifiedYear
FROM dbo.DIM_DATE;
