CREATE VIEW [dbo].[vw_Violator_RegistrationCounty] AS SELECT 
	  CountyLookupID AS RegistrationCountyLookupID
	, Descr AS RegistrationCounty
	, ParticipatingCounty AS ParticipatingRegistrationCounty
	, CountyGroup AS RegistrationCountyGroup
FROM dbo.CountyLookup;
