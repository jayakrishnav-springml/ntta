CREATE VIEW [dbo].[vw_ViolatorStatus_HvExemptFlag] AS SELECT  INDICATOR_ID AS HvExemptFlag, INDICATOR as HvExempt
FROM dbo.DIM_INDICATOR;
