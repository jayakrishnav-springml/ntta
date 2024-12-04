CREATE VIEW [dbo].[vw_Violator_Bankruptcy_FilingDate] AS SELECT  
		[DATE]					AS FilingDate 
	, MONTH_WEEK				AS FilingDateMonthWeek
	, DATE_FULL					AS FilingDateDateStr 
	, DATE_YEAR_MONTH			AS FilingDateYearMonth
	, DATE_QUARTER				AS FilingDateQuarter
	, DATE_YEAR					AS FilingDateYear
FROM dbo.DIM_DATE;
