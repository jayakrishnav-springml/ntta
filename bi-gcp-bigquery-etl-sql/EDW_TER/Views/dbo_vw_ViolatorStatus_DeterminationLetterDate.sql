CREATE VIEW [dbo].[vw_ViolatorStatus_DeterminationLetterDate] AS SELECT  
	  [DATE]			AS DeterminationLetterDate 
	, MONTH_WEEK		AS DeterminationLetterDateMonthWeek
	, DATE_FULL			AS DeterminationLetterDateDateStr 
	, DATE_YEAR_MONTH	AS DeterminationLetterDateYearMonth
	, DATE_QUARTER		AS DeterminationLetterDateQuarter
	, DATE_YEAR			AS DeterminationLetterDateYear
FROM dbo.DIM_DATE;
