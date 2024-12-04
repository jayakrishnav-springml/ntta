CREATE VIEW [dbo].[vw_Vrb_RemovedDate] AS SELECT  
	  [DATE]					AS RemovedDate 
	, MONTH_WEEK				AS RemovedDateMonthWeek
	, DATE_FULL					AS RemovedDateDateStr 
	, DATE_YEAR_MONTH			AS RemovedDateYearMonth
	, DATE_QUARTER				AS RemovedDateQuarter
	, DATE_YEAR					AS RemovedDateYear
FROM dbo.DIM_DATE;
