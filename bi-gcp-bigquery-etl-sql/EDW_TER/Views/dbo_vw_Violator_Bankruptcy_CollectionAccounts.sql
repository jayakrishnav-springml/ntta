CREATE VIEW [dbo].[vw_Violator_Bankruptcy_CollectionAccounts] AS SELECT  INDICATOR_ID AS CollectionAccounts, INDICATOR as CollectionAccountsDesc
FROM dbo.DIM_INDICATOR;
