CREATE VIEW [dbo].[vw_Violator_ViolatorAddressState] AS SELECT StateLookupId AS ViolatorAddressStateLookupID, StateCode AS ViolatorAddressState, Descr AS ViolatorAddressStateName, State_Latitude AS ViolatorAddressStateLatitude , State_Longitude AS ViolatorAddressStateLongitude
FROM dbo.StateLookup;
