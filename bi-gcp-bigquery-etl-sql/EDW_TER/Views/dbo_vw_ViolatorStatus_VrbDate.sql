CREATE VIEW [dbo].[vw_ViolatorStatus_VrbDate] AS SELECT  
	  [DATE]			AS VrbDate 
	, MONTH_WEEK		AS VrbDateMonthWeek
	, DATE_FULL			AS VrbDateDateStr 
	, DATE_YEAR_MONTH	AS VrbDateYearMonth
	, DATE_QUARTER		AS VrbDateQuarter
	, DATE_YEAR			AS VrbDateYear
FROM dbo.DIM_DATE;
