CREATE VIEW [dbo].[vw_VIOLATIONS_LAST_VIOL_INVOICE_DATE] AS SELECT  
		[DATE]					AS LAST_VIOL_INVOICE_DATE 
	, MONTH_WEEK				AS LAST_VIOL_INVOICE_DATEMonthWeek
	, DATE_FULL					AS LAST_VIOL_INVOICE_DATEDateStr 
	, DATE_YEAR_MONTH			AS LAST_VIOL_INVOICE_DATEYearMonth
	, DATE_QUARTER				AS LAST_VIOL_INVOICE_DATEQuarter
	, DATE_YEAR					AS LAST_VIOL_INVOICE_DATEYear
FROM dbo.DIM_DATE;
