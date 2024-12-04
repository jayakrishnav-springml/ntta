CREATE VIEW [dbo].[vw_ViolatorStatus_TermDate] AS SELECT  
	  [DATE]			AS TermDate 
	, MONTH_WEEK		AS TermDateMonthWeek
	, DATE_FULL			AS TermDateDateStr 
	, DATE_YEAR_MONTH	AS TermDateYearMonth
	, DATE_QUARTER		AS TermDateQuarter
	, DATE_YEAR			AS TermDateYear
FROM dbo.DIM_DATE;
