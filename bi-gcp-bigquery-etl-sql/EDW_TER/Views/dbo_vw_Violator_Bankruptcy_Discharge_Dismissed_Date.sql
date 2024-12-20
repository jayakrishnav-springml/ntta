CREATE VIEW [dbo].[vw_Violator_Bankruptcy_Discharge_Dismissed_Date] AS SELECT  
		[DATE]					AS Discharge_Dismissed_Date 
	, MONTH_WEEK				AS Discharge_Dismissed_DateMonthWeek
	, DATE_FULL					AS Discharge_Dismissed_DateDateStr 
	, DATE_YEAR_MONTH			AS Discharge_Dismissed_DateYearMonth
	, DATE_QUARTER				AS Discharge_Dismissed_DateQuarter
	, DATE_YEAR					AS Discharge_Dismissed_DateYear
FROM dbo.DIM_DATE;
