CREATE VIEW [dbo].[vw_Violator_LicPlateState] AS SELECT StateLookupId AS LicPlateStateLookupID, StateCode AS LicPlateState, Descr AS LicPlateStateName, State_Latitude AS LicPlateStateLatitude , State_Longitude AS LicPlateStateLongitude
FROM dbo.StateLookup;
