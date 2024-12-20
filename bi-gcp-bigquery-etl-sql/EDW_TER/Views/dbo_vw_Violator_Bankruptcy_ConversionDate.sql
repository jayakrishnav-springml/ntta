CREATE VIEW [dbo].[vw_Violator_Bankruptcy_ConversionDate] AS SELECT  
		[DATE]					AS ConversionDate 
	, MONTH_WEEK				AS ConversionDateMonthWeek
	, DATE_FULL					AS ConversionDateDateStr 
	, DATE_YEAR_MONTH			AS ConversionDateYearMonth
	, DATE_QUARTER				AS ConversionDateQuarter
	, DATE_YEAR					AS ConversionDateYear
FROM dbo.DIM_DATE;
