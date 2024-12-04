CREATE VIEW [dbo].[vw_ViolatorStatus_EligRmdyDate] AS SELECT  
	  [DATE]			AS EligRmdyDate 
	, MONTH_WEEK		AS EligRmdyDateMonthWeek
	, DATE_FULL			AS EligRmdyDateDateStr 
	, DATE_YEAR_MONTH	AS EligRmdyDateYearMonth
	, DATE_QUARTER		AS EligRmdyDateQuarter
	, DATE_YEAR			AS EligRmdyDateYear
FROM dbo.DIM_DATE;
