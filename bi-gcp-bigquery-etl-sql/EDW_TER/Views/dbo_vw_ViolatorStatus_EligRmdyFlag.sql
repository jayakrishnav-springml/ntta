CREATE VIEW [dbo].[vw_ViolatorStatus_EligRmdyFlag] AS SELECT  INDICATOR_ID AS EligRmdyFlag, INDICATOR as EligRmdy
FROM dbo.DIM_INDICATOR;
