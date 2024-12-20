CREATE VIEW [dbo].[vw_ViolatorStatus_BanCiteWarnDate] AS SELECT  
	  [DATE]			AS BanCiteWarnDate 
	, MONTH_WEEK		AS BanCiteWarnDateMonthWeek
	, DATE_FULL			AS BanCiteWarnDateDateStr 
	, DATE_YEAR_MONTH	AS BanCiteWarnDateYearMonth
	, DATE_QUARTER		AS BanCiteWarnDateQuarter
	, DATE_YEAR			AS BanCiteWarnDateYear
FROM dbo.DIM_DATE;
