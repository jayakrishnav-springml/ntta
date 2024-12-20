CREATE VIEW [dbo].[vw_Facility] AS SELECT 
      FACILITY_ID			AS FacilityID
    , FACILITY_ABBREV			AS FacilityAbbrev
    , FACILITY_NAME			AS FacilityName
    , AGENCY_ID				AS AgencyID
    , AGENCY_ABBREV			AS AgencyAbbrev
    , AGENCY_NAME			AS AgencyName
    , AGENCY_IS_IOP			AS Agency_Is_IOP_Ind
FROM [dbo].[DIM_FACILITY];
