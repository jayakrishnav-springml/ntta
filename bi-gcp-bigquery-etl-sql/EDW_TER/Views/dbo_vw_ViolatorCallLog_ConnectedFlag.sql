CREATE VIEW [dbo].[vw_ViolatorCallLog_ConnectedFlag] AS SELECT  INDICATOR_ID AS ConnectedFlag, INDICATOR as CallConnected
FROM dbo.DIM_INDICATOR;
