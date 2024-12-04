CREATE VIEW [dbo].[vw_Violator_PaymentAgreement_TodaysDate] AS SELECT  
		[DATE]					AS TodaysDate 
	, MONTH_WEEK				AS TodaysDateMonthWeek
	, DATE_FULL					AS TodaysDateDateStr 
	, DATE_YEAR_MONTH			AS TodaysDateYearMonth
	, DATE_QUARTER				AS TodaysDateQuarter
	, DATE_YEAR					AS TodaysDateYear
FROM dbo.DIM_DATE;
