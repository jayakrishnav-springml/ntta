CREATE VIEW [dbo].[vw_Violator_LatestHvTranDate] AS SELECT  
	  [DATE]			AS LatestHvTranDate 
	, MONTH_WEEK		AS LatestHvTranDateMonthWeek
	, DATE_FULL			AS LatestHvTranDateDateStr 
	, DATE_YEAR_MONTH	AS LatestHvTranDateYearMonth
	, DATE_QUARTER		AS LatestHvTranDateQuarter
	, DATE_YEAR			AS LatestHvTranDateYear
FROM dbo.DIM_DATE;
