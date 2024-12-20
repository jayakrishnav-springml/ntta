CREATE VIEW [dbo].[vw_Violator_EarliestHvTranDate] AS SELECT  
	  [DATE]			AS EarliestHvTranDate 
	, MONTH_WEEK		AS EarliestHvTranDateMonthWeek
	, DATE_FULL			AS EarliestHvTranDateDateStr 
	, DATE_YEAR_MONTH	AS EarliestHvTranDateYearMonth
	, DATE_QUARTER		AS EarliestHvTranDateQuarter
	, DATE_YEAR			AS EarliestHvTranDateYear
FROM dbo.DIM_DATE;
