CREATE VIEW [dbo].[vw_ViolatorStatus_ViolatorStatusTermLookup] AS SELECT  
	  ViolatorStatusTermLookupId 
	, [Descr] AS ViolatorStatusTerm
FROM dbo.ViolatorStatusTermLookup;
