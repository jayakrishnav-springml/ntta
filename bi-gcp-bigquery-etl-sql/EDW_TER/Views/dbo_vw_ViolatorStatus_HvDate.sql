CREATE VIEW [dbo].[vw_ViolatorStatus_HvDate] AS SELECT  
	  [DATE]			AS HvDate 
	, MONTH_WEEK		AS HvDateMonthWeek
	, DATE_FULL			AS HvDateDateStr 
	, DATE_YEAR_MONTH	AS HvDateYearMonth
	, DATE_QUARTER		AS HvDateQuarter
	, DATE_YEAR			AS HvDateYear
FROM dbo.DIM_DATE;
