CREATE VIEW [dbo].[vw_Violator_PaymentAgreement_DueDate] AS SELECT  
		[DATE]					AS DueDate 
	, MONTH_WEEK				AS DueDateMonthWeek
	, DATE_FULL					AS DueDateDateStr 
	, DATE_YEAR_MONTH			AS DueDateYearMonth
	, DATE_QUARTER				AS DueDateQuarter
	, DATE_YEAR					AS DueDateYear
FROM dbo.DIM_DATE;
