CREATE VIEW [dbo].[vw_ViolatorStatus_ViolatorStatusLookup] AS SELECT  
	  ViolatorStatusLookupId 
	, [Descr] AS ViolatorStatus
FROM dbo.ViolatorStatusLookup;
