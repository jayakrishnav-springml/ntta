CREATE VIEW [dbo].[vw_Violator_PaymentAgreement_PaymentAgreementFlag] AS SELECT  
	  INDICATOR_ID AS PaymentAgreementFlag
	, INDICATOR AS PaymentAgreementFlagDesc
FROM dbo.DIM_INDICATOR;
