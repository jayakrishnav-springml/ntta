CREATE VIEW [dbo].[vw_Vrb_RejectionDate] AS SELECT  
		[DATE]					AS RejectionDate 
	, MONTH_WEEK				AS RejectionDateMonthWeek
	, DATE_FULL					AS RejectionDateDateStr 
	, DATE_YEAR_MONTH			AS RejectionDateYearMonth
	, DATE_QUARTER				AS RejectionDateQuarter
	, DATE_YEAR					AS RejectionDateYear
FROM dbo.DIM_DATE;
