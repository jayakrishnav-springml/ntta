CREATE VIEW [dbo].[vw_Violator_Bankruptcy_ClaimFilled] AS SELECT  INDICATOR_ID AS ClaimFilled, INDICATOR as ClaimFilledDesc
FROM dbo.DIM_INDICATOR;
