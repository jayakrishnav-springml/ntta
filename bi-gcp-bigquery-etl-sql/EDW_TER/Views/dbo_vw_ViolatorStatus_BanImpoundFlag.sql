CREATE VIEW [dbo].[vw_ViolatorStatus_BanImpoundFlag] AS SELECT  INDICATOR_ID AS BanImpoundFlag, INDICATOR as BanImpound
FROM dbo.DIM_INDICATOR;
