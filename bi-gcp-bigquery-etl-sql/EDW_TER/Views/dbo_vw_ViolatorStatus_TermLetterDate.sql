CREATE VIEW [dbo].[vw_ViolatorStatus_TermLetterDate] AS SELECT  
	  [DATE]			AS TermLetterDate 
	, MONTH_WEEK		AS TermLetterDateMonthWeek
	, DATE_FULL			AS TermLetterDateDateStr 
	, DATE_YEAR_MONTH	AS TermLetterDateYearMonth
	, DATE_QUARTER		AS TermLetterDateQuarter
	, DATE_YEAR			AS TermLetterDateYear
FROM dbo.DIM_DATE;
