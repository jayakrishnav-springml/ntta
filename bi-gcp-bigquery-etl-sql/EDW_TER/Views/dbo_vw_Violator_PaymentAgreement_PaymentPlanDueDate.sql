CREATE VIEW [dbo].[vw_Violator_PaymentAgreement_PaymentPlanDueDate] AS SELECT  
		[DATE]					AS PaymentPlanDueDate 
	, MONTH_WEEK				AS PaymentPlanDueDateMonthWeek
	, DATE_FULL					AS PaymentPlanDueDateDateStr 
	, DATE_YEAR_MONTH			AS PaymentPlanDueDateYearMonth
	, DATE_QUARTER				AS PaymentPlanDueDateQuarter
	, DATE_YEAR					AS PaymentPlanDueDateYear
FROM dbo.DIM_DATE;
