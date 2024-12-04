CREATE VIEW [dbo].[vw_Vrb_AcknowledgedDate] AS SELECT  
		[DATE]					AS AcknowledgedDate 
	, MONTH_WEEK				AS AcknowledgedDateMonthWeek
	, DATE_FULL					AS AcknowledgedDateDateStr 
	, DATE_YEAR_MONTH			AS AcknowledgedDateYearMonth
	, DATE_QUARTER				AS AcknowledgedDateQuarter
	, DATE_YEAR					AS AcknowledgedDateYear
FROM dbo.DIM_DATE;
