CREATE VIEW [dbo].[vw_Violator_DriversLicenseState] AS SELECT StateLookupId AS DriversLicenseStateLookupID, StateCode AS DriversLicenseState, Descr AS DriversLicenseStateName, State_Latitude AS DriversLicenseStateLatitude , State_Longitude AS DriversLicenseStateLongitude
FROM dbo.StateLookup;
