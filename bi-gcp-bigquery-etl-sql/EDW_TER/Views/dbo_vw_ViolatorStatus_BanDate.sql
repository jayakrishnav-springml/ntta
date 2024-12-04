CREATE VIEW [dbo].[vw_ViolatorStatus_BanDate] AS SELECT  
	  [DATE]			AS BanDate 
	, MONTH_WEEK		AS BanDateMonthWeek
	, DATE_FULL			AS BanDateDateStr 
	, DATE_YEAR_MONTH	AS BanDateYearMonth
	, DATE_QUARTER		AS BanDateQuarter
	, DATE_YEAR			AS BanDateYear
FROM dbo.DIM_DATE;
