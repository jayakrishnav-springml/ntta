CREATE VIEW [dbo].[vw_ViolatorStatus_BanLetterDate] AS SELECT  
	  [DATE]			AS BanLetterDate 
	, MONTH_WEEK		AS BanLetterDateMonthWeek
	, DATE_FULL			AS BanLetterDateDateStr 
	, DATE_YEAR_MONTH	AS BanLetterDateYearMonth
	, DATE_QUARTER		AS BanLetterDateQuarter
	, DATE_YEAR			AS BanLetterDateYear
FROM dbo.DIM_DATE;
