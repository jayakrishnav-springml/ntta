CREATE VIEW [dbo].[vw_Violator_PaymentAgreement_PaidInFull] AS SELECT  INDICATOR_ID AS PaidInFull, INDICATOR as PaidInFullDesc
FROM dbo.DIM_INDICATOR;
