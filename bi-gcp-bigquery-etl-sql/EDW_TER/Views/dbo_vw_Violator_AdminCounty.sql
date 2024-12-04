CREATE VIEW [dbo].[vw_Violator_AdminCounty] AS SELECT 
	  CountyLookupID AS AdminCountyLookupID
	, Descr AS AdminCounty
	, ParticipatingCounty AS ParticipatingAdminCounty
	, CountyGroup AS AdminCountyGroup
FROM dbo.CountyLookup;
