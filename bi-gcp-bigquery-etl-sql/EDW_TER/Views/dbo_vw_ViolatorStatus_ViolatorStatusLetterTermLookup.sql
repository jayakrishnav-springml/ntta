CREATE VIEW [dbo].[vw_ViolatorStatus_ViolatorStatusLetterTermLookup] AS SELECT  
	  ViolatorStatusLetterTermLookupId 
	, [Descr] AS ViolatorStatusLetterTerm
FROM dbo.ViolatorStatusLetterTermLookup;
