CREATE VIEW [dbo].[vw_Violator_SecondaryDriversLicenseState] AS SELECT StateLookupId AS SecondaryDriversLicenseStateLookupID, StateCode AS SecondaryDriversLicenseState, Descr AS SecondaryDriversLicenseStateName , State_Latitude AS SecondaryDriversLicenseStateLatitude , State_Longitude AS SecondaryDriversLicenseStateLongitude
FROM dbo.StateLookup;
