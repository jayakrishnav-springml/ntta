CREATE VIEW [dbo].[vw_ViolatorCallLog_CallFlag] AS SELECT  
	  INDICATOR_ID AS CallFlag
	, INDICATOR AS CallFlagDesc
FROM dbo.DIM_INDICATOR;
