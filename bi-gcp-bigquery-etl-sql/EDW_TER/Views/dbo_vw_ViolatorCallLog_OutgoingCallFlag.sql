CREATE VIEW [dbo].[vw_ViolatorCallLog_OutgoingCallFlag] AS SELECT  INDICATOR_ID AS OutgoingCallFlag, INDICATOR as CallConnected
FROM dbo.DIM_INDICATOR;
