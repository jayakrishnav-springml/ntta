CREATE VIEW [dbo].[vw_ViolatorStatus_HvExemptDate] AS SELECT  
	  [DATE]			AS HvExemptDate 
	, MONTH_WEEK		AS HvExemptDateMonthWeek
	, DATE_FULL			AS HvExemptDateDateStr 
	, DATE_YEAR_MONTH	AS HvExemptDateYearMonth
	, DATE_QUARTER		AS HvExemptDateQuarter
	, DATE_YEAR			AS HvExemptDateYear
FROM dbo.DIM_DATE;
