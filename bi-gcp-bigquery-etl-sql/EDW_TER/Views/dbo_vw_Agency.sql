CREATE VIEW [dbo].[vw_Agency] AS SELECT 
      AGENCY_ID				AS AgencyID
    , AGENCY_ABBREV			AS AgencyAbbrev
    , AGENCY_NAME			AS AgencyName
    , AGENCY_IS_IOP			AS Agency_Is_IOP_Ind
FROM [dbo].[DIM_AGENCY];
