CREATE VIEW [dbo].[vw_Violator_Bankruptcy_BankruptcyFlag] AS SELECT  
	  INDICATOR_ID AS BankruptcyFlag
	, INDICATOR AS BankruptcyFlagDesc
FROM dbo.DIM_INDICATOR;
