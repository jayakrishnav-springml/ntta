CREATE VIEW [dbo].[vw_ViolatorStatus_Mart_ReportDate_Monthly] AS SELECT  
	  [DATE]			AS ReportDate 
	--, MONTH_WEEK		AS ReportDateMonthWeek
	--, DATE_FULL			AS ReportDateDateStr 
	, DATE_YEAR_MONTH		AS ReportDateYearMonth
--	, DATE_YEAR_MONTH		AS ReportYearMonth
	--, DATE_QUARTER		AS ReportDateQuarter
	--, DATE_YEAR			AS ReportDateYear
FROM dbo.DIM_DATE
WHERE DatePart(d,[DATE]) = 1;
