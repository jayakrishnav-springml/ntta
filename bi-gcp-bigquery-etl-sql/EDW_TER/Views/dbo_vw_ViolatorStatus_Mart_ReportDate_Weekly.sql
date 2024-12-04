CREATE VIEW [dbo].[vw_ViolatorStatus_Mart_ReportDate_Weekly] AS SELECT  
	  [DATE]			AS ReportDate 
	, MONTH_WEEK		AS ReportDateMonthWeek
--	, MONTH_WEEK		AS ReportMonthWeek
	--, DATE_FULL			AS ReportDateDateStr 
	--, DATE_YEAR_MONTH		AS ReportDateYearMonth
	--, DATE_QUARTER		AS ReportDateQuarter
	--, DATE_YEAR			AS ReportDateYear
FROM dbo.DIM_DATE
WHERE DatePart(dw,[DATE])=2;
