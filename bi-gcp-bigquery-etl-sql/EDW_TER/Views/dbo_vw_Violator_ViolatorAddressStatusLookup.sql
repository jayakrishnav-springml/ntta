CREATE VIEW [dbo].[vw_Violator_ViolatorAddressStatusLookup] AS SELECT  
	  ViolatorAddressStatusLookupId 
	, [Descr] AS ViolatorAddressStatus
FROM dbo.ViolatorAddressStatusLookup;
