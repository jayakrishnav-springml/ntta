CREATE VIEW [dbo].[vw_ViolatorStatus_BanCiteWarnFlag] AS SELECT  INDICATOR_ID AS BanCiteWarnFlag, INDICATOR as BanCiteWarn
FROM dbo.DIM_INDICATOR;
