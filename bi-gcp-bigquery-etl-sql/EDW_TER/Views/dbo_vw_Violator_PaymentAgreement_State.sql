CREATE VIEW [dbo].[vw_Violator_PaymentAgreement_State] AS SELECT   STATE_CODE as State, STATE_NAME, STATE_LATITUDE, STATE_LONGITUDE
FROM dbo.DIM_State;
