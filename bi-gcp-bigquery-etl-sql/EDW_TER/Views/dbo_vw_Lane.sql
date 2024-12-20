CREATE VIEW [dbo].[vw_Lane] AS SELECT 
      LANE_ID					AS LaneID
    , LANE_ABBREV				AS LaneAbbrev
    , LANE_NAME					AS LaneName
	, LANE_DIRECTION			AS LaneDirection
    , PLAZA_ID					AS PlazaID
    , PLAZA_ABBREV				AS PlazaAbbrev
    , PLAZA_NAME				AS PlazaName
    , PLAZA_LATITUDE			AS PlazaLatitude
    , PLAZA_LONGITUDE			AS PlazaLongitude
    , FACILITY_ID				AS FacilityID
    , FACILITY_ABBREV			AS FacilityAbbrev
    , FACILITY_NAME				AS FacilityName
    , AGENCY_ID					AS AgencyID
    , AGENCY_ABBREV				AS AgencyAbbrev
    , AGENCY_NAME				AS AgencyName
    , AGENCY_IS_IOP				AS Agency_Is_IOP_Ind
FROM [dbo].[DIM_LANE];
