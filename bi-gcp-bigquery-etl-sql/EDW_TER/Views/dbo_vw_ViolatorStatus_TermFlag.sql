CREATE VIEW [dbo].[vw_ViolatorStatus_TermFlag] AS SELECT  INDICATOR_ID AS TermFlag, INDICATOR as Term
FROM dbo.DIM_INDICATOR;
