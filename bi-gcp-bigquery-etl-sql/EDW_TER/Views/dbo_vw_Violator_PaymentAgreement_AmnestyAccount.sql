CREATE VIEW [dbo].[vw_Violator_PaymentAgreement_AmnestyAccount] AS SELECT  INDICATOR_ID AS AmnestyAccount, INDICATOR as AmnestyAccountDesc
FROM dbo.DIM_INDICATOR;
