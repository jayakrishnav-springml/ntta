CREATE VIEW [dbo].[vw_Violator_RegistrationDateNextYear] AS SELECT YEAR_ID AS RegistrationDateNextYear, YEAR AS RegistrationDateNextYearDescr
FROM dbo.DIM_YEAR;
