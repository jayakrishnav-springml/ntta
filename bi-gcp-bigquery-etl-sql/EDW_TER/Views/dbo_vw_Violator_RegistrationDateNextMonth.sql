CREATE VIEW [dbo].[vw_Violator_RegistrationDateNextMonth] AS SELECT MONTH_ID AS RegistrationDateNextMonth, MONTH AS RegistrationDateNextMonthDescr
FROM dbo.DIM_MONTH;
