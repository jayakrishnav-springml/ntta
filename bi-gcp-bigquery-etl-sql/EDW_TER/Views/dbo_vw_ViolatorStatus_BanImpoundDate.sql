CREATE VIEW [dbo].[vw_ViolatorStatus_BanImpoundDate] AS SELECT  
	  [DATE]			AS BanImpoundDate 
	, MONTH_WEEK		AS BanImpoundDateMonthWeek
	, DATE_FULL			AS BanImpoundDateDateStr 
	, DATE_YEAR_MONTH	AS BanImpoundDateYearMonth
	, DATE_QUARTER		AS BanImpoundDateQuarter
	, DATE_YEAR			AS BanImpoundDateYear
FROM dbo.DIM_DATE;
