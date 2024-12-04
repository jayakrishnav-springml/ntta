CREATE VIEW [dbo].[vw_Vrb_SentDate] AS SELECT  
		[DATE]					AS SentDate 
	, MONTH_WEEK				AS SentDateMonthWeek
	, DATE_FULL					AS SentDateDateStr 
	, DATE_YEAR_MONTH			AS SentDateYearMonth
	, DATE_QUARTER				AS SentDateQuarter
	, DATE_YEAR					AS SentDateYear
FROM dbo.DIM_DATE;
