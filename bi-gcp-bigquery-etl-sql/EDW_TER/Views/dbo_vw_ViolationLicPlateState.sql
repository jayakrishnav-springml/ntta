CREATE VIEW [dbo].[vw_ViolationLicPlateState] AS SELECT
	  StateLookupId				AS ViolationLicPlateStateID
    , StateCode					AS ViolationLicPlateState
    , Descr						AS ViolationLicPlateStateName
    , State_Latitude			AS ViolationLicPlateStateLatitude
    , State_Longitude			AS ViolationLicPlateStateLongitude
FROM dbo.StateLookup;
