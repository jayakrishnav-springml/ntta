CREATE VIEW [dbo].[vw_Violator_Bankruptcy_Assets] AS SELECT  INDICATOR_ID AS Assets, INDICATOR as AssetsDesc
FROM dbo.DIM_INDICATOR;
